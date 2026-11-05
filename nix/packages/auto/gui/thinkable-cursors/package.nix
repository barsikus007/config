{
  lib,
  imagemagick,
  python3,
  stdenvNoCC,
  win2xcur,
  xcursorgen,
}:

stdenvNoCC.mkDerivation {
  pname = "thinkable-cursors";
  version = "1.0";

  src = ./thinkable.tar.xz;

  nativeBuildInputs = [
    win2xcur
    xcursorgen
    imagemagick
    python3
  ];

  installPhase = ''
    runHook preInstall

    cursor_dir="$out/share/icons/THINKABLE/cursors"
    mkdir --parents "$cursor_dir"

    win2xcur --output-dir "$cursor_dir" *.cur *.ani

    # generate 24px and proper sizes across all cursors
    python3 ${./generate-multisize.py} "$cursor_dir"

    cat << 'EOF' > "$out/share/icons/THINKABLE/index.theme"
    [Icon Theme]
    Name=THINKABLE
    Comment=THINKABLE cursor theme
    Inherits=breeze_cursors
    EOF

    cd "$cursor_dir"

    # default / arrow
    ln --symbolic aero_arrow default
    ln --symbolic aero_arrow left_ptr
    ln --symbolic aero_arrow arrow
    ln --symbolic aero_arrow top_left_arrow
    ln --symbolic aero_arrow right_ptr

    # pointer / link
    ln --symbolic aero_link pointer
    ln --symbolic aero_link pointing_hand
    ln --symbolic aero_link hand1
    ln --symbolic aero_link hand2
    ln --symbolic aero_link e29285e634086352946a0e7090d73106
    ln --symbolic aero_link 9d800788f1b08800ae810202380a0822

    # busy / wait
    ln --symbolic aero_busy wait
    ln --symbolic aero_busy watch

    # working / progress
    ln --symbolic aero_working progress
    ln --symbolic aero_working left_ptr_watch
    ln --symbolic aero_working half-busy
    ln --symbolic aero_working 00000000000000020006000e7e9ffc3f
    ln --symbolic aero_working 08e8e1c95fe2fc01f976f1e063a24ccd
    ln --symbolic aero_working 3ecb610c1bf2410f44200f48c40d3599

    # helpsel
    ln --symbolic aero_helpsel help
    ln --symbolic aero_helpsel question_arrow
    ln --symbolic aero_helpsel whats_this
    ln --symbolic aero_helpsel 5c6cd98b3f3ebcb1f9c7f1c204630408
    ln --symbolic aero_helpsel d965f792e2fb46e31f0520307a847358

    # move
    ln --symbolic aero_move move
    ln --symbolic aero_move size_all
    ln --symbolic aero_move all-scroll
    ln --symbolic aero_move fleur
    ln --symbolic aero_move 4498f0e0c1937ffe01fd06f973665830
    ln --symbolic aero_move 9081237383d90e509aa00f00170e968f

    # resize
    ln --symbolic aero_ns ns-resize
    ln --symbolic aero_ns v_double_arrow
    ln --symbolic aero_ns size_ver
    ln --symbolic aero_ns n-resize
    ln --symbolic aero_ns s-resize
    ln --symbolic aero_ns row-resize
    ln --symbolic aero_ns top_side
    ln --symbolic aero_ns bottom_side
    ln --symbolic aero_ns 00008160000006810000408080010102

    ln --symbolic aero_ew ew-resize
    ln --symbolic aero_ew h_double_arrow
    ln --symbolic aero_ew size_hor
    ln --symbolic aero_ew e-resize
    ln --symbolic aero_ew w-resize
    ln --symbolic aero_ew col-resize
    ln --symbolic aero_ew left_side
    ln --symbolic aero_ew right_side
    ln --symbolic aero_ew 028006030e0e7ebffc7f7070c0600140

    ln --symbolic aero_nwse nwse-resize
    ln --symbolic aero_nwse size_bdiag
    ln --symbolic aero_nwse nw-resize
    ln --symbolic aero_nwse se-resize
    ln --symbolic aero_nwse top_left_corner
    ln --symbolic aero_nwse bottom_right_corner
    ln --symbolic aero_nwse c708870ac22e0812490b02f3041822dd

    ln --symbolic aero_nesw nesw-resize
    ln --symbolic aero_nesw size_fdiag
    ln --symbolic aero_nesw ne-resize
    ln --symbolic aero_nesw sw-resize
    ln --symbolic aero_nesw top_right_corner
    ln --symbolic aero_nesw bottom_left_corner
    ln --symbolic aero_nesw fcf1c3c702032982941e1e044501cb82

    # not-allowed
    ln --symbolic aero_unavail not-allowed
    ln --symbolic aero_unavail crossed_circle
    ln --symbolic aero_unavail forbidden
    ln --symbolic aero_unavail circle
    ln --symbolic aero_unavail 03b6e0fcb3499374a867c041f52298f0

    # pencil & up
    ln --symbolic aero_pen pencil
    ln --symbolic aero_pen draft
    ln --symbolic aero_up up-arrow
    ln --symbolic aero_up center_ptr

    runHook postInstall
  '';

  meta = {
    description = "THINKABLE cursor theme";
    platforms = lib.platforms.linux;
  };
}
