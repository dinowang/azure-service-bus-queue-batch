using System;
using System.Collections.Generic;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace consumer
{
    public static class SBConsumer
    {
        [FunctionName("SBConsumer")]
        public static void Run(
            [ServiceBusTrigger("messages", Connection = "ServiceBusConnection")] string[] messages,
            ILogger log)
        {
            log.LogInformation($"C# ServiceBus queue trigger function processed messages count: {messages.Length}");
            foreach (var message in messages)
            {
                log.LogWarning($"\t{message}");
            }
        }
    }
}
