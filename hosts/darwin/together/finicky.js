export default {
  defaultBrowser: { name: "@FIREFOX_APP@", appType: "path" },
  options: {
    hideIcon: true,
    keepRunning: true
  },
  handlers: [
    {
      match: /^https?:\/\/([^/]+\.)?granola\.(ai|so)([:/?#]|$)/,
      browser: { name: "com.google.Chrome", appType: "bundleId" },
    },
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
      match: /together/i,
      browser: { name: "com.google.Chrome", appType: "bundleId" },
    },
    {
      // cloudflare zero trust / warp enrolment and login
      match: [
        /cloudflareaccess\.com/,
        /cloudflareclient\.com/,
        /teams\.cloudflare\.com/,
        /one\.dash\.cloudflare\.com/,
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
          "com.1password.1password",
          "com.cloudflare.1dot1dot1dot1.macos",
        ].includes(opener?.bundleId ?? ""),
      browser: { name: "com.google.Chrome", appType: "bundleId" },
    },
  ],
};
