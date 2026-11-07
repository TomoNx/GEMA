<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GEMA - Real-Time Audio Streaming Umrah & Haji</title>

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=figtree:400,500,600,700&display=swap" rel="stylesheet" />

    <!-- Tailwind CSS (CDN Fallback + Vite) -->
    <script src="https://cdn.tailwindcss.com"></script>
    @if (file_exists(public_path('build/manifest.json')))
        @vite(['resources/css/app.css', 'resources/js/app.js'])
    @endif
</head>
<body class="bg-gradient-to-b from-green-800 to-green-950 min-h-screen text-gray-100 font-sans flex flex-col justify-between">
    <!-- Navbar -->
    <header class="w-full max-w-6xl mx-auto px-6 py-6 flex items-center justify-between">
        <div class="flex items-center gap-3">
            <span class="text-3xl">🕌</span>
            <div>
                <h1 class="text-2xl font-bold tracking-tight text-white">GEMA</h1>
                <p class="text-xs text-green-200">Umrah & Haji Real-Time Audio</p>
            </div>
        </div>
        <nav class="flex items-center gap-4">
            @auth
                <a href="{{ route('dashboard') }}" class="px-4 py-2 rounded-lg bg-green-600 hover:bg-green-500 text-white font-medium text-sm transition">
                    Buka Dashboard
                </a>
            @else
                <a href="{{ route('login') }}" class="px-4 py-2 rounded-lg bg-white/10 hover:bg-white/20 text-white font-medium text-sm backdrop-blur transition border border-white/20">
                    Login Guide
                </a>
            @endauth
        </nav>
    </header>

    <!-- Hero Content -->
    <main class="w-full max-w-4xl mx-auto px-6 py-12 flex-1 flex flex-col justify-center">
        <div class="text-center mb-10">
            <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-green-700/50 border border-green-500/30 text-green-200 text-xs mb-4">
                <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
                WebRTC SFU Ultra-Low Latency (~120ms)
            </div>
            <h2 class="text-3xl sm:text-5xl font-extrabold text-white tracking-tight leading-tight mb-4">
                Bimbingan Audio Manasik & Doa Langsung ke Jamaah
            </h2>
            <p class="text-base sm:text-lg text-green-100/90 max-w-2xl mx-auto">
                Solusi audio streaming jernih tanpa alat receiver terpisah. Muthawwif menyiarkan bimbingan audio dan teks doa, jamaah mendengarkan langsung dari ponsel.
            </p>
        </div>

        <!-- Portals: Guide & Jamaah -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 max-w-3xl mx-auto w-full">
            <!-- Portal Jamaah -->
            <div class="bg-white/95 rounded-2xl p-6 text-gray-900 shadow-xl border border-green-200">
                <div class="flex items-center gap-3 mb-4">
                    <span class="text-3xl">🎧</span>
                    <div>
                        <h3 class="text-xl font-bold text-green-900">Portal Jamaah</h3>
                        <p class="text-xs text-gray-500">Mendengarkan siaran Muthawwif</p>
                    </div>
                </div>
                <p class="text-sm text-gray-600 mb-4">
                    Punya kode atau slug room dari Muthawwif? Masukkan di bawah untuk langsung terhubung ke room:
                </p>
                <form onsubmit="event.preventDefault(); const slug = document.getElementById('roomSlugInput').value.trim(); if(slug) window.location.href='/room/' + slug;" class="space-y-3">
                    <input id="roomSlugInput" type="text" placeholder="Masukkan slug / kode room..." class="w-full px-4 py-2.5 rounded-lg border border-gray-300 focus:ring-2 focus:ring-green-600 focus:outline-none text-sm" required>
                    <button type="submit" class="w-full py-2.5 rounded-lg bg-green-700 hover:bg-green-800 text-white font-semibold text-sm transition shadow">
                        Masuk Room Siaran →
                    </button>
                </form>
            </div>

            <!-- Portal Guide / Muthawwif -->
            <div class="bg-white/10 backdrop-blur-md rounded-2xl p-6 text-white shadow-xl border border-white/20 flex flex-col justify-between">
                <div>
                    <div class="flex items-center gap-3 mb-4">
                        <span class="text-3xl">🎙️</span>
                        <div>
                            <h3 class="text-xl font-bold text-white">Portal Guide</h3>
                            <p class="text-xs text-green-200">Muthawwif & Tour Leader</p>
                        </div>
                    </div>
                    <p class="text-sm text-green-100/90 mb-4">
                        Buat room siaran, bagikan QR code ke jamaah, kontrol mikrofon (Push-to-Talk), dan ganti bacaan doa secara real-time.
                    </p>
                </div>
                @auth
                    <a href="{{ route('dashboard') }}" class="w-full py-2.5 rounded-lg bg-emerald-500 hover:bg-emerald-600 text-white font-semibold text-sm text-center transition shadow block">
                        Buka Dashboard Guide →
                    </a>
                @else
                    <a href="{{ route('login') }}" class="w-full py-2.5 rounded-lg bg-white text-green-900 hover:bg-green-50 font-semibold text-sm text-center transition shadow block">
                        Login sebagai Guide →
                    </a>
                @endauth
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer class="w-full text-center py-6 text-xs text-green-300/80">
        &copy; {{ date('Y') }} GEMA — Arsitektur Cloud Computing Real-Time Audio Streaming Umrah & Haji
    </footer>
</body>
</html>
