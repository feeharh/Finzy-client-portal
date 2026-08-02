export default async function PortalPage({
  params,
}: {
  params: Promise<{ accessToken: string }>;
}) {
  const { accessToken } = await params;

  return (
    <main className="mx-auto w-full max-w-3xl px-6 py-12">
      <h1 className="text-3xl font-semibold tracking-tight">Customer Portal</h1>
      <p className="mt-3 text-stone-600">
        Secure portal for token ending in …{accessToken.slice(-6)} — Phase 3
        implementation.
      </p>
    </main>
  );
}
