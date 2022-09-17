using System.Text.Json.Serialization;

namespace WakaWatch.Models.Github
{
    public class PullRequestEvent
    {
        [JsonPropertyName("action")]
        public string Action { get; set; }

        [JsonPropertyName("pull_request")]
        public PullRequest PullRequest { get; set; }
    }
}