using System;
using Microsoft.Azure.Devices.Client;
using Newtonsoft.Json;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using System.IO;
using System.Collections.Generic;
using Microsoft.Extensions.Configuration;


namespace donutsimulator
{
    class Program
    {
        static DeviceClient deviceClient;
        static string iotHubUri;
        static string deviceKey;
        
        static int qcFailPercentage;

        static int numberOfStores;

        static int maxNumberOfDonuts;

        static int msDelayBetweenMessages;

        static List<string> donutTypes = new List<string>() { "chocolate", "blueberry", "boston creme", "coconut", "plain", "valentines heart" };
        private static async void SendDeviceToCloudMessagesAsync()
        {
            Random rand = new Random();

      

            while(true) 
            {
                var donutsProduced = rand.Next(maxNumberOfDonuts);

                // qc-check every donut, based on simulated failure rate
                // every donut has a potential chance of being flagged (broken, misshaped, dropped, etc)
                var totalQCFail = 0;
                for(int i=0; i < donutsProduced; i++)
                {
                    var randomFailure = rand.Next(1,100);
                    if( randomFailure > (100-qcFailPercentage))
                        totalQCFail++;
                }

                // Just for fun: Let's assume there's one store (store #1) still selling an expired promotion (valentines heart)
                var currentStoreId = rand.Next(numberOfStores)+1;
                var donutTypeCount = (currentStoreId == 1 ? donutTypes.Count : donutTypes.Count - 1);

                var donutDataPoint = new
                {
                    id = Guid.NewGuid(),
                    storeId = currentStoreId,
                    eventTime = DateTime.UtcNow,
                    donutType = donutTypes[rand.Next(donutTypeCount)],
                    donutCount = rand.Next(maxNumberOfDonuts),
                    qcIssueCount = totalQCFail,
                    partitionId = "1"
                };
                var messageString = JsonConvert.SerializeObject(donutDataPoint);
                var message = new Message(Encoding.ASCII.GetBytes(messageString));
                
                await deviceClient.SendEventAsync(message);
                Console.WriteLine("{0} > Sending message: {1}", DateTime.Now, messageString);

                await Task.Delay(msDelayBetweenMessages);
            }
        }
        
        public static void Main(string[] args)
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json");
            var appConfig = builder.Build();

            iotHubUri = appConfig["iotHubUri"];
            deviceKey = appConfig["deviceKey"];
            qcFailPercentage = Int32.Parse(appConfig["qcFailPercentage"]);
            numberOfStores = Int32.Parse(appConfig["numberOfStores"]);
            maxNumberOfDonuts = Int32.Parse(appConfig["maxNumberOfDonuts"]);
            msDelayBetweenMessages = Int32.Parse(appConfig["msDelayBetweenMessages"]);

            Console.WriteLine("Donut machine starting...\n");
            deviceClient = DeviceClient.Create(iotHubUri, new DeviceAuthenticationWithRegistrySymmetricKey ("donutshop", deviceKey), TransportType.Mqtt);
            deviceClient.ProductInfo = "Donut data";
            SendDeviceToCloudMessagesAsync();
            Console.ReadLine();
        }
    }
}
