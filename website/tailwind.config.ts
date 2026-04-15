import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}"
  ],
  theme: {
    extend: {
      colors: {
        plum: {
          50: "#faf5ff",
          100: "#f3e8ff",
          200: "#e7d4ff",
          300: "#d4b1ff",
          400: "#ba80ff",
          500: "#9f53ff",
          600: "#7b32d4",
          700: "#6125a8",
          800: "#4a1f7d",
          900: "#2f124f"
        },
        sun: "#f5c542",
        aqua: "#35c7c1",
        ink: "#20152f",
        cream: "#fff9f2"
      },
      boxShadow: {
        glow: "0 20px 70px rgba(123, 50, 212, 0.18)"
      },
      borderRadius: {
        "4xl": "2rem"
      }
    }
  },
  plugins: []
};

export default config;
