import Link from "next/link";

export default function Home() {
  return (
    <main className="mx-auto flex min-h-full w-full max-w-3xl flex-col justify-center px-6 py-16">
      <p className="text-sm font-medium uppercase tracking-widest text-stone-500">
        Finzy Alterations
      </p>
      <h1 className="mt-3 text-4xl font-semibold tracking-tight text-stone-900">
        Finzy Client Portal
      </h1>
      <p className="mt-4 max-w-xl text-lg leading-relaxed text-stone-600">
        Request alterations, track garments, and access your measurements in
        one place.
      </p>

      <div className="mt-10 flex flex-col gap-3 sm:flex-row">
        <Link
          href="/book"
          className="inline-flex items-center justify-center rounded-md bg-stone-900 px-5 py-3 text-sm font-medium text-white transition hover:bg-stone-800"
        >
          Request an Alteration
        </Link>
        <Link
          href="/admin/login"
          className="inline-flex items-center justify-center rounded-md border border-stone-300 bg-white px-5 py-3 text-sm font-medium text-stone-900 transition hover:bg-stone-100"
        >
          Administrator Login
        </Link>
      </div>
    </main>
  );
}
