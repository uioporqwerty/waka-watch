using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System.Net.Http;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Collections.Generic;

namespace WakaWatch.Function
{
    public class WakaTimeSummaryResponse {
        [JsonPropertyName("cummulative_total")]
        public CummulativeTotal CummulativeTotal { get; set; }
    }

    public class CummulativeTotal {
        [JsonPropertyName("seconds")]
        public double Seconds { get; set; }
    }

    public class WakaTimeGoalsResponse {
        [JsonPropertyName("data")]
        public IEnumerable<Goal> Goals { get; set; }
    }


    public class Goal {
        [JsonPropertyName("title")]
        public string Title { get; set; }

        [JsonPropertyName("status_percent_calculated")]
        public double PercentCompleted { get; set; }

        [JsonPropertyName("is_snoozed")]
        public bool IsSnoozed { get; set; }

        [JsonPropertyName("is_enabled")]
        public bool IsEnabled { get; set; }
    }

    public class BackgroundUpdateResponse {
        [JsonPropertyName("total_time_coded_in_seconds")]
        public double TotalTimeCodedInSeconds { get; set; }

        [JsonPropertyName("goals")]
        public IEnumerable<Goal> Goals { get; set; }
    }

    public class ComplicationsHttpTrigger
    {
        private readonly HttpClient _client;
        private readonly string _clientSecret = "";

        private readonly string baseUrl = "https://wakatime.com/api/v1";
        
        public ComplicationsHttpTrigger(IHttpClientFactory httpClientFactory)
        {
            _client = httpClientFactory.CreateClient();
            _clientSecret = Environment.GetEnvironmentVariable("CLIENT_SECRET");
        }

        [FunctionName("backgroundUpdate")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("Retrieving background update data");

            var accessToken = req.Query["access_token"];
            var summaryData = await GetSummaryData(accessToken);
            var goalsData = await GetGoalsData(accessToken);
            var goals = new List<Goal>();

            foreach (var goal in goalsData.Goals) {
                if (goal.IsEnabled && !goal.IsSnoozed) {
                    goals.Add(goal);
                }
            }
            
            var response = new BackgroundUpdateResponse {
                TotalTimeCodedInSeconds = summaryData.CummulativeTotal.Seconds,
                Goals = goals
            };

            return new OkObjectResult(response);
        }

        private async Task<WakaTimeSummaryResponse> GetSummaryData(string accessToken) {
            var summaryResponse = await _client.GetAsync($"{baseUrl}/users/current/summaries?client_secret={_clientSecret}&access_token={accessToken}&range=Today");
            var stream = await summaryResponse.Content.ReadAsStreamAsync();
            return await JsonSerializer.DeserializeAsync<WakaTimeSummaryResponse>(stream);
        }

        private async Task<WakaTimeGoalsResponse> GetGoalsData(string accessToken) {
            var goalsResponse = await _client.GetAsync($"{baseUrl}/users/current/goals?client_secret={_clientSecret}&access_token={accessToken}");
            var stream = await goalsResponse.Content.ReadAsStreamAsync();
            return await JsonSerializer.DeserializeAsync<WakaTimeGoalsResponse>(stream);
        }
    }
}
