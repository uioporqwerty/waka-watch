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
        [JsonPropertyName("id")]
        public string Id { get; set; }

        [JsonPropertyName("title")]
        public string Title { get; set; }

        [JsonPropertyName("status_percent_calculated")]
        public double PercentCompleted { get; set; }

        [JsonPropertyName("is_snoozed")]
        public bool IsSnoozed { get; set; }

        [JsonPropertyName("is_enabled")]
        public bool IsEnabled { get; set; }

        [JsonPropertyName("modified_at")]
        public DateTime? ModifiedAt { get; set; }

        [JsonPropertyName("chart_data")]
        public List<ChartData> ChartData { get; set; }
    }

    public class ChartData { 
        [JsonPropertyName("range_status_reason")]
        public string RangeStatusReason { get; set; }

        [JsonPropertyName("range_status_reason_short")]
        public string ShortRangeStatusReason { get; set; }

        [JsonPropertyName("range_status")]
        public string RangeStatus { get; set; }
    }

    public class BackgroundUpdateResponse {
        [JsonPropertyName("total_time_coded_in_seconds")]
        public double TotalTimeCodedInSeconds { get; set; }

        [JsonPropertyName("goals")]
        public IEnumerable<BackgroundUpdateGoalResponse> Goals { get; set; }
    }

    public class BackgroundUpdateGoalResponse {
        [JsonPropertyName("id")]
        public string Id { get; set; }

        [JsonPropertyName("title")]
        public string Title { get; set; }

        [JsonPropertyName("status_percent_calculated")]
        public double PercentCompleted { get; set; }

        [JsonPropertyName("range_status")]
        public string RangeStatus { get; set; }

        [JsonPropertyName("range_status_reason")]
        public string RangeStatusReason { get; set; }

        [JsonPropertyName("range_status_reason_short")]
        public string ShortRangeStatusReason { get; set; }

        [JsonPropertyName("modified_at")]
        public DateTime? ModifiedAt { get; set; }
    }

    public class BackgroundUpdateHttpTrigger {
        private readonly HttpClient _client;
        private readonly string _clientSecret = "";

        private readonly string baseUrl = "https://wakatime.com/api/v1";
        
        public BackgroundUpdateHttpTrigger(IHttpClientFactory httpClientFactory)
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
            var goals = new List<BackgroundUpdateGoalResponse>();

            foreach (var goal in goalsData.Goals) {
                if (goal.IsEnabled && !goal.IsSnoozed) {
                    var lastDay = goal.ChartData[goal.ChartData.Count - 1];
                    
                    goals.Add(new BackgroundUpdateGoalResponse {
                        Id = goal.Id,
                        Title = goal.Title,
                        PercentCompleted = goal.PercentCompleted,
                        RangeStatusReason = lastDay.RangeStatusReason,
                        ShortRangeStatusReason = lastDay.ShortRangeStatusReason,
                        RangeStatus = lastDay.RangeStatus,
                        ModifiedAt = goal.ModifiedAt
                    });
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
