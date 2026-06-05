"use client";

import { FormEvent, Suspense, useEffect, useState } from "react";
import { useSearchParams } from "next/navigation";
import { siteConfig } from "@/components/site-config";

const firebaseWebApiKey = "AIzaSyAEyocrc4JhgGOmsQh0c9v22RPlSdmbkXg";
const resetPasswordEndpoint =
  `https://identitytoolkit.googleapis.com/v1/accounts:resetPassword?key=${firebaseWebApiKey}`;

type VerifyState = "checking" | "ready" | "invalid";

function ResetPasswordContent() {
  const params = useSearchParams();
  const email = params.get("email") ?? "";
  const oobCode = params.get("oobCode") ?? "";

  const [verifyState, setVerifyState] = useState<VerifyState>("checking");
  const [accountEmail, setAccountEmail] = useState(email);
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    async function verifyCode() {
      if (!oobCode) {
        setVerifyState("invalid");
        setError("Şifre sıfırlama bağlantısı eksik veya bozuk görünüyor.");
        return;
      }

      try {
        const response = await fetch(resetPasswordEndpoint, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ oobCode }),
        });

        const data = (await response.json()) as {
          email?: string;
          error?: { message?: string };
        };

        if (!response.ok) {
          throw new Error(data.error?.message || "INVALID_OOB_CODE");
        }

        if (data.email) {
          setAccountEmail(data.email);
        }

        setVerifyState("ready");
      } catch (verifyError) {
        const message =
          verifyError instanceof Error ? verifyError.message : "INVALID_OOB_CODE";

        setVerifyState("invalid");
        setError(
          message.includes("EXPIRED_OOB_CODE") ||
                  message.includes("INVALID_OOB_CODE")
            ? "Bu şifre sıfırlama bağlantısının süresi dolmuş ya da daha önce kullanılmış."
            : "Şifre sıfırlama bağlantısı doğrulanamadı. Lütfen tekrar iste."
        );
      }
    }

    void verifyCode();
  }, [oobCode]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError("");
    setSuccess("");

    if (password.length < 6) {
      setError("Yeni şifre en az 6 karakter olmalı.");
      return;
    }

    if (password !== confirmPassword) {
      setError("Şifreler birbiriyle aynı değil.");
      return;
    }

    setIsSubmitting(true);

    try {
      const response = await fetch(resetPasswordEndpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          oobCode,
          newPassword: password,
        }),
      });

      const data = (await response.json()) as {
        error?: { message?: string };
      };

      if (!response.ok) {
        throw new Error(data.error?.message || "PASSWORD_RESET_FAILED");
      }

      setSuccess(
        "Şifren güncellendi. Artık uygulamada yeni şifrenle giriş yapabilirsin."
      );
      setPassword("");
      setConfirmPassword("");
    } catch (submitError) {
      const message =
        submitError instanceof Error
          ? submitError.message
          : "PASSWORD_RESET_FAILED";

      setError(
        message.includes("WEAK_PASSWORD")
          ? "Daha güçlü bir şifre seç. En az 6 karakter kullan."
          : "Şifre güncellenemedi. Linkin süresi dolmuş olabilir; uygulamadan yeniden sıfırlama iste."
      );
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <div className="section-shell py-16 sm:py-20">
      <div className="mx-auto max-w-2xl rounded-[32px] border border-plum-100 bg-white p-6 shadow-sm sm:p-10">
        <p className="text-xs font-black uppercase tracking-[0.24em] text-plum-700">
          Şifre Sıfırlama
        </p>
        <h1 className="mt-3 text-3xl font-black tracking-tight text-ink sm:text-4xl">
          Hesabın için yeni bir şifre oluştur
        </h1>
        <p className="mt-4 text-sm leading-7 text-slate-600 sm:text-base">
          {accountEmail
            ? `${accountEmail} hesabı için yeni şifreni belirle.`
            : "Yeni şifreni belirleyip uygulamaya güvenle geri dönebilirsin."}
        </p>

        {verifyState === "checking" ? (
          <div className="mt-8 rounded-3xl bg-slate-50 p-5 text-sm text-slate-600">
            Bağlantı doğrulanıyor...
          </div>
        ) : null}

        {verifyState === "invalid" ? (
          <div className="mt-8 rounded-3xl border border-red-200 bg-red-50 p-5 text-sm leading-7 text-red-700">
            <p className="font-bold">Bağlantı kullanılamıyor</p>
            <p className="mt-2">{error}</p>
            <p className="mt-4">
              Uygulamadan tekrar “Şifremi Unuttum” diyerek yeni bağlantı iste.
              Mail görünmüyorsa spam/junk klasörünü de kontrol et.
            </p>
          </div>
        ) : null}

        {verifyState === "ready" ? (
          <form className="mt-8 space-y-5" onSubmit={handleSubmit}>
            <label className="block">
              <span className="mb-2 block text-sm font-bold text-ink">
                Yeni şifre
              </span>
              <input
                type="password"
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                className="w-full rounded-2xl border border-slate-200 px-4 py-3 text-base outline-none transition focus:border-plum-500"
                placeholder="En az 6 karakter"
                autoComplete="new-password"
              />
            </label>

            <label className="block">
              <span className="mb-2 block text-sm font-bold text-ink">
                Yeni şifre tekrar
              </span>
              <input
                type="password"
                value={confirmPassword}
                onChange={(event) => setConfirmPassword(event.target.value)}
                className="w-full rounded-2xl border border-slate-200 px-4 py-3 text-base outline-none transition focus:border-plum-500"
                placeholder="Şifreni tekrar yaz"
                autoComplete="new-password"
              />
            </label>

            {error ? (
              <div className="rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
                {error}
              </div>
            ) : null}

            {success ? (
              <div className="rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
                {success}
              </div>
            ) : null}

            <button
              type="submit"
              disabled={isSubmitting}
              className="inline-flex w-full items-center justify-center rounded-full bg-plum-700 px-5 py-3 text-sm font-bold text-white transition hover:bg-plum-800 disabled:cursor-not-allowed disabled:opacity-70"
            >
              {isSubmitting ? "Şifre güncelleniyor..." : "Şifreyi Güncelle"}
            </button>

            <p className="text-xs leading-6 text-slate-500">
              Giriş ekranına dönüp yeni şifrenle oturum açabilirsin. Sorun
              sürerse{" "}
              <a
                href={`mailto:${siteConfig.supportEmail}`}
                className="font-bold text-plum-700"
              >
                {siteConfig.supportEmail}
              </a>{" "}
              adresine yaz.
            </p>
          </form>
        ) : null}
      </div>
    </div>
  );
}

export default function ResetPasswordPage() {
  return (
    <Suspense
      fallback={
        <div className="section-shell py-16 sm:py-20">
          <div className="mx-auto max-w-2xl rounded-[32px] border border-plum-100 bg-white p-6 shadow-sm sm:p-10">
            <p className="text-sm text-slate-600">Bağlantı hazırlanıyor...</p>
          </div>
        </div>
      }
    >
      <ResetPasswordContent />
    </Suspense>
  );
}
