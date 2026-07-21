export default {
  defaultBrowser: { name: "@FIREFOX_APP@", appType: "path" },
  options: {
    hideIcon: true,
    keepRunning: true
  },
  handlers: [
    {
      match: [
        /amazonaws\.com/,
        /aws\.amazon\.com/,
        /awsapps\.com/,
      ],
      browser: { name: "com.google.Chrome", appType: "bundleId" },
    },
    {
      match: [
        /okta\.com/,
        /oktapreview\.com/,
        /okta-emea\.com/,
        /oktacdn\.com/,
      ],
      browser: { name: "com.google.Chrome", appType: "bundleId" },
    },
    {
      // any together.* domain (subdomains + tlds), e.g. cloud.together.ai
      match: [
        /(^|[./])together\.[a-z]{2,}/,
      ],
      browser: { name: "com.google.Chrome", appType: "bundleId" },
    },
    {
      // together's github org (github.com/togethercomputer/*) -> chrome
      match: [
        /github\.com\/togethercomputer(\/|$)/,
      ],
      browser: { name: "com.google.Chrome", appType: "bundleId" },
    },
    {
      match: (_url, { opener }) =>
        [
          "com.tinyspeck.slackmacgap",
          "us.zoom.xos",
          "notion.id",
          "com.linear",
          "com.okta.mobile",
        ].includes(opener?.bundleId ?? ""),
      browser: { name: "com.google.Chrome", appType: "bundleId" },
    },
  ],
};
