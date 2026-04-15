"use client";

import { FormEvent, useState } from "react";
import { siteConfig } from "@/components/site-config";

export function SupportForm() {
  const [sent, setSent] = useState(false);

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    const subject = encodeURIComponent(`Ben Yaparım Destek | ${form.get("topic")}`);
    const body = encodeURIComponent(
      [
        `Ad Soyad: ${form.get("name")}`,
        `E-posta: ${form.get("email")}`,
        `Konu: ${form.get("topic")}`,
        "",
        `${form.get("message")}`
      ].join("\n")
    );

    window.location.href = `mailto:${siteConfig.supportEmail}?subject=${subject}&body=${body}`;
    setSent(true);
  };

  return (
    <div className="glass-card rounded-4xl p-6 sm:p-8">
      <h2 className="text-2xl font-black text-ink">İletişim formu</h2>
      <p className="mt-3 text-sm leading-6 text-slate-600">
        Formu doldurduğunda varsayılan e-posta uygulaman açılır ve destek talebin hazır biçimde oluşturulur.
      </p>
      <form className="mt-6 space-y-4" onSubmit={handleSubmit}>
        <input
          name="name"
          required
          placeholder="Ad Soyad"
          className="w-full rounded-3xl border border-plum-100 bg-white px-4 py-4 outline-none transition focus:border-plum-400"
        />
        <input
          name="email"
          type="email"
          required
          placeholder="E-posta"
          className="w-full rounded-3xl border border-plum-100 bg-white px-4 py-4 outline-none transition focus:border-plum-400"
        />
        <select
          name="topic"
          className="w-full rounded-3xl border border-plum-100 bg-white px-4 py-4 outline-none transition focus:border-plum-400"
          defaultValue="Hesap"
        >
          <option>Hesap</option>
          <option>Teklifler</option>
          <option>Sipariş</option>
          <option>Bildirimler</option>
          <option>Diğer</option>
        </select>
        <textarea
          name="message"
          required
          rows={6}
          placeholder="Sorununu veya talebini kısaca anlat."
          className="w-full rounded-[1.75rem] border border-plum-100 bg-white px-4 py-4 outline-none transition focus:border-plum-400"
        />
        <button
          type="submit"
          className="rounded-full bg-plum-700 px-6 py-4 text-sm font-bold text-white transition hover:bg-plum-800"
        >
          Destek talebi oluştur
        </button>
        {sent ? (
          <p className="text-sm font-semibold text-plum-700">
            E-posta taslağın hazır. Göndermeden önce bilgileri son kez kontrol edebilirsin.
          </p>
        ) : null}
      </form>
    </div>
  );
}
