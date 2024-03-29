using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System.Net.Http;
using System.Text.Json;
using System.Collections.Generic;
using WakaWatch.Models;
using WakaWatch.Models.WakaTime;
using System.Linq;

namespace WakaWatch.Function
{
    public class BackgroundUpdateHttpTrigger
    {
        private readonly HttpClient _client;
        private readonly string _clientSecret = "";
        private readonly string baseUrl = "https://wakatime.com/api/v1";
        private ILogger _log;

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
            try {
                _log = log;

                var accessToken = req.Query["access_token"];

                if (string.IsNullOrEmpty(accessToken))
                {
                    _log.LogError("access_token is missing.");
                    return new BadRequestResult();
                }

                var summaryData = await GetSummaryData(accessToken);
                _log.LogInformation("Summary data: " + JsonSerializer.Serialize(summaryData));

                var totalCodingTime = summaryData.Data
                                                ?.FirstOrDefault()
                                                ?.Categories
                                                .Where(x => x.Name == "Coding")
                                                .Sum(x => x.TotalSeconds) ?? 0.0;

                var goalsData = await GetGoalsData(accessToken);
                _log.LogInformation("Goals data: " + JsonSerializer.Serialize(goalsData));
                var goals = new List<BackgroundUpdateGoalResponse>();

                foreach (var goal in goalsData.Goals)
                {
                    if (goal.IsEnabled && !goal.IsSnoozed)
                    {
                        var lastDay = goal.ChartData[^1];

                        goals.Add(new BackgroundUpdateGoalResponse
                        {
                            Id = goal.Id,
                            Title = goal.Title,
                            PercentCompleted = goal.PercentCompleted,
                            RangeStatusReason = lastDay.RangeStatusReason,
                            ShortRangeStatusReason = lastDay.ShortRangeStatusReason,
                            RangeStatus = lastDay.RangeStatus,
                            ModifiedAt = goal.ModifiedAt,
                            IsInverse = goal.IsInverse,
                            GoalSeconds = lastDay.GoalSeconds,
                            ActualSeconds = lastDay.ActualSeconds
                        });
                    }
                }

                var response = new BackgroundUpdateResponse
                {
                    TotalTimeCodedInSeconds = totalCodingTime,
                    Goals = goals
                };

                _log.LogInformation(JsonSerializer.Serialize(response));

                return new OkObjectResult(response);
            } catch(Exception ex) {
                _log.LogError(ex, ex.Message);
                return new BadRequestResult();
            }
        }

        private async Task<SummaryResponse> GetSummaryData(string accessToken)
        {
            var requestUrl = $"{baseUrl}/users/current/summaries?client_secret={_clientSecret}&access_token={accessToken}&range=Today";
            var summaryResponse = await _client.GetAsync(requestUrl);

            var stream = await summaryResponse.Content.ReadAsStreamAsync();
            return await JsonSerializer.DeserializeAsync<SummaryResponse>(stream);
        }

        private async Task<GoalsResponse> GetGoalsData(string accessToken)
        {
            var requestUrl = $"{baseUrl}/users/current/goals?client_secret={_clientSecret}&access_token={accessToken}";
            var goalsResponse = await _client.GetAsync(requestUrl);

            var stream = await goalsResponse.Content.ReadAsStreamAsync();
            return await JsonSerializer.DeserializeAsync<GoalsResponse>(stream);
        }
    }
}
