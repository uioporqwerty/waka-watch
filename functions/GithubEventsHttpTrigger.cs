using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Security.Cryptography;
using System.Text;

namespace WakaWatch.Function
{
    public class GithubEventsHttpTrigger
    {

        private ILogger _log;
        private readonly string _githubSecret = "";

        private readonly string ShaPrefix = "sha256=";

        public GithubEventsHttpTrigger()
        {
            _githubSecret = Environment.GetEnvironmentVariable("GITHUB_WEBHOOK_SECRET");
        }

        [FunctionName("githubEvents")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            _log = log;

            var secretHeaderKey = req.Headers["x-hub-signature-256"];
            
            if (secretHeaderKey.Count == 0 || !IsGithubAuthorized(secretHeaderKey, req))  {
                _log.LogInformation("Invalid github HTTP event triggered.");
                
                return new UnauthorizedResult();
            }
            
            _log.LogInformation("Starting githubEvents");
            
            return new OkObjectResult(null);
        }

        private bool IsGithubAuthorized(string githubSignature, HttpRequest req) {
            var signature = githubSignature[ShaPrefix.Length..];
            var secret = Encoding.ASCII.GetBytes(_githubSecret);

            string payload;
            req.Body.Position = 0;
            
            using (var reader = new StreamReader(req.Body, leaveOpen: true))
            {
                payload = reader.ReadToEnd();
            }

            if (string.IsNullOrEmpty(payload)) {
                return false;
            }

            using (var sha = new HMACSHA256(secret))
            {
                var hash = sha.ComputeHash(Encoding.UTF8.GetBytes(payload));

                var hashString = ToHexString(hash);

                if (hashString.Equals(signature))
                {
                    return true;
                }
            }

            return false;
        }

        private string ToHexString(byte[] bytes)
        {
            var builder = new StringBuilder(bytes.Length * 2);
            foreach (byte b in bytes)
            {
                builder.AppendFormat("{0:x2}", b);
            }

            return builder.ToString();
        }
    }
}
