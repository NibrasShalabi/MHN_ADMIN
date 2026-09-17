[33mcommit 109ecfe5114a79cd21fe7831c211d5da44e7d816[m[33m ([m[1;36mHEAD[m[33m -> [m[1;32mmaster[m[33m)[m
Author: asmaajaz-alt <rwlaalahmr@gmail.com>
Date:   Sat Sep 12 16:10:41 2026 +0300

    Rebuild UI per section 7 spec, add suppliers feature, testing foundation
    
    - Restructure onboarding (4 slides) and About page (shared content, wide cards)
    
    - Unify icon color to flame across app; reverse product name/price colors
    
    - Redesign bottom nav (gold hairline, always-fire icons) and cart card (fire gradient, oval->rectangle, bottom-sheet checkout)
    
    - Add always-visible category search on home
    
    - Add Suppliers feature (list, detail, catalog reuse via CatalogScope.supplier)
    
    - Rebuild fitness section as a true 3-sided pyramid (CustomPainter)
    
    - Move loyalty explainer card from orders to loyalty store page
    
    - Add responsive web layout (top nav >=800px, per-page AppBar suppressed)
    
    - Fix promo swiper: real infinite autoplay loop + actual image rendering (was gradient-only placeholder)
    
    - Add ArefRuqaa display font; darken drawer/about hero gradient for contrast
    
    - Extract shared InlineError and StepButton widgets (were duplicated)
    
    - Add CartCubit unit tests
