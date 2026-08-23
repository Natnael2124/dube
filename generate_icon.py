import os
from PIL import Image, ImageDraw, ImageFont

def generate_dube_icon():
    os.makedirs('assets/icon', exist_ok=True)
    
    # Render at 2048x2048 for supersampled sharpness, then downscale to 1024x1024
    S = 2048
    img = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Background: Deep slate #0F172A with subtle soft radial gradient
    bg_color = (15, 23, 42, 255) # #0F172A
    draw.rectangle([0, 0, S, S], fill=bg_color)
    
    # Subtle inner glow / vignette in background
    for r in range(400, 1000, 20):
        alpha = int(18 * (1.0 - (r - 400) / 600))
        glow_color = (16, 185, 129, alpha) # Emerald #10B981
        draw.ellipse([S//2 - r, S//2 - r, S//2 + r, S//2 + r], fill=glow_color)

    # 2. Main Financial Ledger Book Card
    # Dimensions
    book_x0 = 420
    book_y0 = 360
    book_x1 = 1628
    book_y1 = 1688
    radius = 96
    
    # Soft drop shadow for ledger
    shadow_color = (2, 6, 23, 140)
    for offset in range(30, 0, -4):
        draw.rounded_rectangle(
            [book_x0 + offset//2, book_y0 + offset, book_x1 + offset//2, book_y1 + offset],
            radius=radius,
            fill=(2, 6, 23, int(15 * (offset / 30)))
        )

    # Ledger Cover Body: Deep emerald gradient #064E3B to #047857
    draw.rounded_rectangle(
        [book_x0, book_y0, book_x1, book_y1],
        radius=radius,
        fill=(6, 78, 59, 255), # #064E3B
        outline=(16, 185, 129, 180), # Emerald outline
        width=12
    )

    # Ledger Spine / Left Binding Band: #0F172A / Dark Emerald
    spine_w = 200
    draw.rounded_rectangle(
        [book_x0, book_y0, book_x0 + spine_w, book_y1],
        radius=radius,
        fill=(4, 47, 46, 255) # Deep teal #042F2E
    )
    # Spine right edge divider
    draw.line(
        [(book_x0 + spine_w, book_y0), (book_x0 + spine_w, book_y1)],
        fill=(16, 185, 129, 220),
        width=10
    )
    
    # Spine stitch/binder dashes
    for y_stitch in range(book_y0 + 160, book_y1 - 120, 160):
        draw.rounded_rectangle(
            [book_x0 + 70, y_stitch, book_x0 + 130, y_stitch + 28],
            radius=14,
            fill=(52, 211, 153, 230) # Mint
        )

    # 3. Inner Ledger Page Area (Crisp White/Slate)
    page_x0 = book_x0 + spine_w + 50
    page_y0 = book_y0 + 60
    page_x1 = book_x1 - 60
    page_y1 = book_y1 - 60
    page_radius = 48

    draw.rounded_rectangle(
        [page_x0, page_y0, page_x1, page_y1],
        radius=page_radius,
        fill=(248, 250, 252, 255), # Crisp slate 50
        outline=(226, 232, 240, 255),
        width=4
    )

    # Ledger Header Bar on Page
    draw.rounded_rectangle(
        [page_x0 + 40, page_y0 + 40, page_x1 - 40, page_y0 + 180],
        radius=24,
        fill=(241, 245, 249, 255)
    )
    
    # Header Balance Badge (Emerald)
    draw.rounded_rectangle(
        [page_x0 + 60, page_y0 + 65, page_x0 + 380, page_y0 + 155],
        radius=20,
        fill=(16, 185, 129, 255) # Emerald 500
    )
    # Small icon dot / symbol inside badge
    draw.ellipse(
        [page_x0 + 85, page_y0 + 90, page_x0 + 130, page_y0 + 135],
        fill=(255, 255, 255, 255)
    )
    draw.rectangle(
        [page_x0 + 150, page_y0 + 102, page_x0 + 340, page_y0 + 122],
        fill=(255, 255, 255, 240)
    )

    # Header Metric Pill on right
    draw.rounded_rectangle(
        [page_x1 - 280, page_y0 + 75, page_x1 - 60, page_y0 + 145],
        radius=16,
        fill=(226, 232, 240, 255)
    )
    draw.rectangle(
        [page_x1 - 250, page_y0 + 100, page_x1 - 90, page_y0 + 120],
        fill=(100, 116, 139, 255)
    )

    # Ledger Grid Rows (Credit / Debit entries with status dots)
    row_y_start = page_y0 + 240
    row_gap = 160
    
    rows_data = [
        {'bar_w': 380, 'amt_w': 160, 'dot_color': (16, 185, 129, 255), 'badge_color': (209, 250, 229, 255)}, # Active/Paid
        {'bar_w': 320, 'amt_w': 180, 'dot_color': (245, 158, 11, 255), 'badge_color': (254, 243, 199, 255)}, # Pending
        {'bar_w': 420, 'amt_w': 200, 'dot_color': (16, 185, 129, 255), 'badge_color': (209, 250, 229, 255)}, # Paid
        {'bar_w': 280, 'amt_w': 150, 'dot_color': (16, 185, 129, 255), 'badge_color': (209, 250, 229, 255)}, # Paid
        {'bar_w': 350, 'amt_w': 190, 'dot_color': (244, 63, 94, 255),  'badge_color': (255, 228, 230, 255)}, # Overdue
    ]

    for i, row in enumerate(rows_data):
        curr_y = row_y_start + i * row_gap
        if curr_y + 110 > page_y1 - 40:
            break

        # Subtle row container
        draw.rounded_rectangle(
            [page_x0 + 40, curr_y, page_x1 - 40, curr_y + 110],
            radius=20,
            fill=(248, 250, 252, 255),
            outline=(241, 245, 249, 255),
            width=2
        )

        # Status Circle Dot
        draw.ellipse(
            [page_x0 + 70, curr_y + 35, page_x0 + 110, curr_y + 75],
            fill=row['dot_color']
        )

        # Description bar
        draw.rounded_rectangle(
            [page_x0 + 135, curr_y + 38, page_x0 + 135 + row['bar_w'], curr_y + 58],
            radius=8,
            fill=(51, 65, 85, 255) # Slate 700
        )
        # Sub-bar
        draw.rounded_rectangle(
            [page_x0 + 135, curr_y + 68, page_x0 + 135 + int(row['bar_w'] * 0.55), curr_y + 82],
            radius=6,
            fill=(148, 163, 184, 255) # Slate 400
        )

        # Right side Amount pill badge
        amt_x1 = page_x1 - 70
        amt_x0 = amt_x1 - row['amt_w']
        draw.rounded_rectangle(
            [amt_x0, curr_y + 30, amt_x1, curr_y + 80],
            radius=14,
            fill=row['badge_color']
        )
        draw.rounded_rectangle(
            [amt_x0 + 20, curr_y + 48, amt_x1 - 20, curr_y + 62],
            radius=6,
            fill=row['dot_color']
        )

    # 4. Prominent Golden Bookmark Ribbon hanging from top of ledger
    ribbon_x = book_x0 + spine_w + 140
    ribbon_w = 90
    ribbon_h = 240
    ribbon_y0 = book_y0 - 20
    ribbon_pts = [
        (ribbon_x, ribbon_y0),
        (ribbon_x + ribbon_w, ribbon_y0),
        (ribbon_x + ribbon_w, ribbon_y0 + ribbon_h),
        (ribbon_x + ribbon_w // 2, ribbon_y0 + ribbon_h - 40),
        (ribbon_x, ribbon_y0 + ribbon_h),
    ]
    # Ribbon shadow
    draw.polygon([(x + 10, y + 10) for x, y in ribbon_pts], fill=(2, 6, 23, 80))
    # Ribbon body (Gold / Amber #F59E0B to #D97706)
    draw.polygon(ribbon_pts, fill=(245, 158, 11, 255))
    draw.line([ribbon_pts[0], ribbon_pts[1], ribbon_pts[2], ribbon_pts[3], ribbon_pts[4], ribbon_pts[0]], fill=(217, 119, 6, 255), width=4)

    # 5. Floating Modern Financial Badge in bottom right corner (ETB / Check Token)
    token_r = 170
    token_cx = book_x1 - 60
    token_cy = book_y1 - 60
    
    # Token glow & shadow
    for toffset in range(24, 0, -4):
        draw.ellipse(
            [token_cx - token_r - toffset, token_cy - token_r + toffset,
             token_cx + token_r + toffset, token_cy + token_r + toffset],
            fill=(2, 6, 23, int(18 * (toffset / 24)))
        )
        
    # Outer ring
    draw.ellipse(
        [token_cx - token_r, token_cy - token_r, token_cx + token_r, token_cy + token_r],
        fill=(15, 23, 42, 255), # Slate 900
        outline=(16, 185, 129, 255), # Emerald 500
        width=18
    )
    # Inner circle
    draw.ellipse(
        [token_cx - token_r + 28, token_cy - token_r + 28, token_cx + token_r - 28, token_cy + token_r - 28],
        fill=(16, 185, 129, 255) # Emerald 500
    )
    
    # Crisp Checkmark inside token
    check_pts = [
        (token_cx - 70, token_cy - 5),
        (token_cx - 20, token_cy + 45),
        (token_cx + 70, token_cy - 45)
    ]
    draw.line(check_pts, fill=(255, 255, 255, 255), width=34, joint="curve")

    # Downscale from 2048 to 1024 with Lanczos for ultra sharp edges
    final_icon = img.resize((1024, 1024), Image.Resampling.LANCZOS)
    output_path = os.path.join('assets', 'icon', 'app_icon.png')
    final_icon.save(output_path, 'PNG', optimize=True)
    print(f"Generated {output_path} ({os.path.getsize(output_path)} bytes)")

if __name__ == '__main__':
    generate_dube_icon()
