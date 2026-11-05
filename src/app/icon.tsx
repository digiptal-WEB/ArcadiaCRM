import { ImageResponse } from "next/og";

// DIGIPTAL brand mark favicon — Deep Ocean (#010C28) rounded container
// with aqua (#1FCCEA) accent and glass border, matching the sidebar logo.
export const runtime = "edge";
export const size = { width: 32, height: 32 };
export const contentType = "image/png";

export default function Icon() {
  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          background: "#010C28",
          borderRadius: 7,
          border: "1.5px solid rgba(31, 204, 234, 0.6)",
        }}
      >
        <svg
          width="18"
          height="18"
          viewBox="0 0 24 24"
          fill="none"
          stroke="#1FCCEA"
          strokeWidth="2.5"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
        </svg>
      </div>
    ),
    { ...size },
  );
}
