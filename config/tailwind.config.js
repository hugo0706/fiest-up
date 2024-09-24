const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
      colors: {
        "spotify-gray-secondary": "#121212",
        "spotify-gray-clear": "#191919",
      },
      animation: {
        party: "backlightEffect 8s linear infinite",
      },
      keyframes: {
        backlightEffect: {
          "0%": {
            background:
              "radial-gradient(circle, rgba(255, 0, 0, 0.2) 0%, transparent 38%), #000000",
          },
          "25%": {
            background:
              "radial-gradient(circle, rgba(0, 255, 0, 0.2) 0%, transparent 38%), #000000",
          },
          "50%": {
            background:
              "radial-gradient(circle, rgba(0, 0, 255, 0.2) 0%, transparent 38%), #000000",
          },
          "75%": {
            background:
              "radial-gradient(circle, rgba(255, 0, 255, 0.2) 0%, transparent 38%), #000000",
          },
          "85%": {
            background:
              "radial-gradient(circle, rgba(150, 150, 150, 0.2) 0%, transparent 38%), #000000",
          },
          "100%": {
            background:
              "radial-gradient(circle, rgba(255, 0, 0, 0.2) 0%, transparent 38%), #000000",
          },
        },
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
  ],
};
