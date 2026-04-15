import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Messages",
  robots: {
    index: false,
    follow: false
  }
};

export default function MessagesPage() {
  return (
    <div className="section-shell py-20">
      <div className="glass-card mx-auto max-w-3xl rounded-4xl p-8 text-center">
        <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">İkinci Faz</p>
        <h1 className="mt-3 text-4xl font-black text-ink">Mesajlaşma deneyimi yakında</h1>
        <p className="mt-4 text-base leading-7 text-slate-600">
          `/messages` sayfası ikinci faz için hazırlandı. İleride web üzerinden de teklif ve iletişim akışını aynı sıcaklıkta sürdürebiliriz.
        </p>
      </div>
    </div>
  );
}
