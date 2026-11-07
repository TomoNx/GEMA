<?php

namespace App\Http\Controllers;

use App\Models\Room;
use App\Models\Prayer;
use App\Services\LiveKitService;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use SimpleSoftwareIO\QrCode\Facades\QrCode;

class GuideController extends Controller
{
    public function __construct(
        private LiveKitService $liveKitService
    ) {}

    /**
     * Show guide dashboard
     */
    public function dashboard()
    {
        $rooms = Room::where('guide_id', auth()->id())
            ->withCount('participants')
            ->latest()
            ->get();

        return view('guide.dashboard', compact('rooms'));
    }

    /**
     * Create new room
     */
    public function createRoom(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
        ]);

        $room = Room::create([
            'name' => $request->name,
            'slug' => Str::slug($request->name) . '-' . Str::random(6),
            'guide_id' => auth()->id(),
            'is_active' => false,
        ]);

        return redirect()->route('guide.room', $room->id);
    }

    /**
     * Show room control panel
     */
    public function showRoom(Room $room)
    {
        $this->authorize('manage', $room);

        $prayers = Prayer::all();
        $token = $this->liveKitService->generateGuideToken($room->slug, auth()->user()->email);
        $livekitHost = config('services.livekit.ws_url');
        $qrCode = QrCode::size(200)->generate(route('room.entry', $room->slug));

        return view('guide.room', compact('room', 'prayers', 'token', 'livekitHost', 'qrCode'));
    }

    /**
     * Toggle room active status
     */
    public function toggleRoom(Room $room)
    {
        $this->authorize('manage', $room);

        $room->update(['is_active' => !$room->is_active]);

        return back()->with('status', $room->is_active ? 'Room diaktifkan' : 'Room dinonaktifkan');
    }

    /**
     * Update current prayer
     */
    public function updatePrayer(Request $request, Room $room)
    {
        $this->authorize('manage', $room);

        $room->update(['current_prayer_id' => $request->prayer_id]);

        return response()->json(['success' => true]);
    }

    /**
     * Mute all participants (fallback HTTP endpoint)
     */
    public function muteAll(Room $room)
    {
        $this->authorize('manage', $room);

        return response()->json(['success' => true]);
    }

    /**
     * Unmute all participants (fallback HTTP endpoint)
     */
    public function unmuteAll(Room $room)
    {
        $this->authorize('manage', $room);

        return response()->json(['success' => true]);
    }

    /**
     * Delete room (soft delete)
     */
    public function deleteRoom(Room $room)
    {
        $this->authorize('delete', $room);

        // Validasi: Room aktif tidak bisa dihapus
        if ($room->is_active) {
            return redirect()->route('dashboard')->with('error', 'Room yang masih aktif tidak bisa dihapus. Nonaktifkan terlebih dahulu.');
        }

        // Validasi: Room dengan jamaah online tidak bisa dihapus
        try {
            $client = $this->liveKitService->getRoomServiceClient();
            $participants = $client->listParticipants($room->slug)->getParticipants();
            if (count($participants) > 0) {
                return redirect()->route('dashboard')->with('error', 'Room masih memiliki jamaah di dalamnya. Tunggu semua jamaah keluar terlebih dahulu.');
            }
        } catch (\Throwable $e) {
            // Room tidak ada di LiveKit atau server belum terhubung, lanjutkan hapus
        }

        // Set deleted_by before soft delete
        $room->update(['deleted_by' => auth()->id()]);
        $room->delete();

        return redirect()->route('dashboard')->with('status', 'Room berhasil dihapus');
    }

    /**
     * Get real-time participant count from LiveKit
     */
    public function getParticipantCount(Room $room)
    {
        $this->authorize('manage', $room);

        try {
            $client = $this->liveKitService->getRoomServiceClient();
            $participants = $client->listParticipants($room->slug)->getParticipants();
            $count = count($participants);
        } catch (\Throwable $e) {
            $count = 0;
        }

        return response()->json(['count' => $count]);
    }
}
