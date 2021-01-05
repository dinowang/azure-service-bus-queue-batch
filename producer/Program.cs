using System;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Core;

namespace producer
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var random = new Random();
            var connectionString = "";
            var topicSender = new MessageSender(connectionString, "messages");

            while (true)
            {
                var s = $"Message timestamp {DateTime.UtcNow}, {Guid.NewGuid()}";
                var message = new Message(Encoding.UTF8.GetBytes(s));
                message.TimeToLive = TimeSpan.FromMinutes(5);
                await topicSender.SendAsync(message);

                Console.WriteLine(s);
                Thread.Sleep(random.Next(200));
            }
        }
    }
}
