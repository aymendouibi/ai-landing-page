class TemplateHtmlCompiler {
  /// Compiles a WebsiteDocument Map into standalone, fully styled HTML for live preview.
  static String compileHtml(Map<String, dynamic> doc) {
    final site = doc['site'] is Map ? Map<String, dynamic>.from(doc['site'] as Map) : <String, dynamic>{};
    final siteName = site['name'] ?? site['title'] ?? 'Preview Website';
    final theme = site['theme'] is Map ? Map<String, dynamic>.from(site['theme'] as Map) : <String, dynamic>{};
    final colors = theme['colors'] is Map ? Map<String, dynamic>.from(theme['colors'] as Map) : <String, dynamic>{};
    final textColors = colors['text'] is Map ? Map<String, dynamic>.from(colors['text'] as Map) : <String, dynamic>{};
    final typography = theme['typography'] is Map ? Map<String, dynamic>.from(theme['typography'] as Map) : <String, dynamic>{};

    final primaryColor = colors['primary'] ?? '#4F46E5';
    final secondaryColor = colors['secondary'] ?? '#64748B';
    final accentColor = colors['accent'] ?? primaryColor;
    final bgColor = colors['background'] ?? '#FFFFFF';
    final surfaceColor = colors['surface'] ?? '#F8FAFC';
    final textPrimary = textColors['primary'] ?? '#0F172A';
    final textSecondary = textColors['secondary'] ?? '#64748B';
    final textInverse = textColors['inverse'] ?? '#FFFFFF';

    final isDarkBg = _isColorDark(bgColor);
    final borderColor = isDarkBg ? 'rgba(255, 255, 255, 0.09)' : 'rgba(0, 0, 0, 0.06)';
    final cardBg = isDarkBg ? surfaceColor : '#FFFFFF';
    final secondaryBtnBg = isDarkBg ? 'rgba(255, 255, 255, 0.1)' : 'rgba(0, 0, 0, 0.05)';

    final headingFont = typography['headingFamily'] ?? 'Playfair Display';
    final bodyFont = typography['bodyFamily'] ?? 'Inter';

    final nav = doc['navigation'] is Map ? Map<String, dynamic>.from(doc['navigation'] as Map) : <String, dynamic>{};
    final rawNavItems = (nav['items'] as List?) ?? [];
    final navItems = rawNavItems.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList();

    final rawPages = (doc['pages'] as List?) ?? [];
    final pages = rawPages.map((p) => p is Map ? Map<String, dynamic>.from(p) : <String, dynamic>{}).toList();
    final activePage = pages.isNotEmpty ? pages.first : null;
    final rawSections = (activePage?['sections'] as List?) ?? [];
    final sections = rawSections.map((s) => s is Map ? Map<String, dynamic>.from(s) : <String, dynamic>{}).toList();

    final hasFooterSection = sections.any((s) => s['component'] == 'footer');
    final sectionsHtml = sections.map((sec) => _renderSection(sec, primaryColor, surfaceColor)).join('\n');

    return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>${_escape(siteName)}</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Playfair+Display:ital,wght@0,400;0,600;0,700;0,800;1,400;1,600&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Space+Grotesk:wght@500;600;700&display=swap" rel="stylesheet">
  <style>
    :root {
      --primary: $primaryColor;
      --secondary: $secondaryColor;
      --accent: $accentColor;
      --bg: $bgColor;
      --surface: $surfaceColor;
      --card-bg: $cardBg;
      --border-color: $borderColor;
      --sec-btn-bg: $secondaryBtnBg;
      --text-primary: $textPrimary;
      --text-secondary: $textSecondary;
      --text-inverse: $textInverse;
      --font-heading: '$headingFont', serif, sans-serif;
      --font-body: '$bodyFont', sans-serif;
    }
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
      -webkit-tap-highlight-color: transparent;
    }
    body {
      background-color: var(--bg);
      color: var(--text-primary);
      font-family: var(--font-body);
      line-height: 1.6;
      font-size: 15px;
      overflow-x: hidden;
    }
    h1, h2, h3, h4 {
      font-family: var(--font-heading);
      color: var(--text-primary);
      line-height: 1.2;
      font-weight: 700;
    }
    .container {
      width: 100%;
      max-width: 600px;
      margin: 0 auto;
      padding: 0 20px;
    }
    /* Navigation Bar */
    .navbar {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 18px 20px;
      background: var(--bg);
      border-bottom: 1px solid var(--border-color);
      position: sticky;
      top: 0;
      z-index: 50;
      backdrop-filter: blur(10px);
    }
    .brand-logo {
      font-family: var(--font-heading);
      font-size: 19px;
      font-weight: 800;
      color: var(--text-primary);
      text-decoration: none;
      letter-spacing: -0.3px;
    }
    .nav-links {
      display: flex;
      align-items: center;
      gap: 12px;
    }
    .nav-btn {
      background: var(--primary);
      color: var(--text-inverse);
      padding: 6px 14px;
      border-radius: 999px;
      font-size: 12.5px;
      font-weight: 600;
      text-decoration: none;
    }
    .menu-icon {
      font-size: 20px;
      color: var(--text-primary);
      cursor: pointer;
    }
    /* Section Wrappers */
    .section {
      padding: 44px 0;
    }
    .section-surface {
      background-color: var(--surface);
    }
    /* Hero */
    .hero-badge {
      display: inline-block;
      font-size: 10.5px;
      font-weight: 800;
      letter-spacing: 1.2px;
      text-transform: uppercase;
      color: var(--primary);
      margin-bottom: 12px;
      padding: 4px 10px;
      border-radius: 999px;
      background: var(--sec-btn-bg);
      border: 1px solid var(--border-color);
    }
    .hero-title {
      font-size: 32px;
      font-weight: 800;
      line-height: 1.15;
      letter-spacing: -0.8px;
      margin-bottom: 14px;
    }
    .hero-sub {
      font-size: 15px;
      color: var(--text-secondary);
      line-height: 1.55;
      margin-bottom: 22px;
    }
    .hero-cta-group {
      display: flex;
      gap: 10px;
      margin-bottom: 24px;
      flex-wrap: wrap;
    }
    .btn-pill-primary {
      background: var(--primary);
      color: var(--text-inverse);
      padding: 12px 22px;
      border-radius: 999px;
      font-size: 13.5px;
      font-weight: 600;
      text-decoration: none;
      display: inline-block;
      box-shadow: 0 4px 14px rgba(0, 0, 0, 0.12);
    }
    .btn-pill-secondary {
      background: var(--sec-btn-bg);
      color: var(--text-primary);
      padding: 12px 20px;
      border-radius: 999px;
      font-size: 13.5px;
      font-weight: 600;
      text-decoration: none;
      display: inline-block;
      border: 1px solid var(--border-color);
    }
    .hero-image-wrap {
      width: 100%;
      border-radius: 20px;
      overflow: hidden;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.12);
      margin-top: 10px;
      border: 1px solid var(--border-color);
    }
    .hero-image-wrap img {
      width: 100%;
      height: 250px;
      object-fit: cover;
      display: block;
    }
    /* Section Headings */
    .sec-header {
      margin-bottom: 26px;
      text-align: center;
    }
    .sec-title {
      font-size: 24px;
      font-weight: 800;
      letter-spacing: -0.4px;
      margin-bottom: 6px;
    }
    .sec-sub {
      font-size: 13.5px;
      color: var(--text-secondary);
      max-width: 480px;
      margin: 0 auto;
    }
    /* Products Grid */
    .products-grid {
      display: grid;
      grid-template-columns: 1fr;
      gap: 16px;
    }
    .product-card {
      background: var(--card-bg);
      border-radius: 16px;
      overflow: hidden;
      border: 1px solid var(--border-color);
      display: flex;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
    }
    .product-thumb {
      width: 110px;
      height: 110px;
      object-fit: cover;
      flex-shrink: 0;
    }
    .product-info {
      padding: 14px;
      display: flex;
      flex-direction: column;
      justify-content: center;
      flex-grow: 1;
    }
    .product-name {
      font-size: 15px;
      font-weight: 700;
      margin-bottom: 3px;
    }
    .product-price {
      font-size: 13.5px;
      font-weight: 800;
      color: var(--primary);
      margin-bottom: 4px;
    }
    .product-desc {
      font-size: 12px;
      color: var(--text-secondary);
      line-height: 1.4;
    }
    /* About / Story */
    .story-card {
      background: var(--card-bg);
      border-radius: 20px;
      overflow: hidden;
      border: 1px solid var(--border-color);
    }
    .story-card img {
      width: 100%;
      height: 200px;
      object-fit: cover;
      display: block;
    }
    .story-content {
      padding: 24px 20px;
    }
    .story-quote {
      font-family: var(--font-heading);
      font-size: 17px;
      font-style: italic;
      color: var(--primary);
      margin-bottom: 12px;
    }
    .story-body {
      font-size: 13.5px;
      color: var(--text-secondary);
      line-height: 1.6;
    }
    /* Features */
    .feature-item {
      background: var(--card-bg);
      padding: 18px;
      border-radius: 14px;
      margin-bottom: 12px;
      border: 1px solid var(--border-color);
    }
    .feature-icon {
      font-size: 20px;
      margin-bottom: 8px;
      display: inline-block;
      color: var(--primary);
    }
    .feature-title {
      font-size: 16px;
      font-weight: 700;
      margin-bottom: 4px;
    }
    .feature-desc {
      font-size: 13px;
      color: var(--text-secondary);
      line-height: 1.5;
    }
    /* Statistics / Metrics */
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 14px;
    }
    .stat-card {
      background: var(--card-bg);
      border: 1px solid var(--border-color);
      border-radius: 16px;
      padding: 20px 16px;
      text-align: center;
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.04);
    }
    .stat-value {
      font-size: 26px;
      font-weight: 800;
      font-family: var(--font-heading);
      color: var(--primary);
      line-height: 1.1;
      margin-bottom: 6px;
    }
    .stat-label {
      font-size: 11.5px;
      font-weight: 700;
      letter-spacing: 0.5px;
      text-transform: uppercase;
      color: var(--text-primary);
      margin-bottom: 2px;
    }
    .stat-desc {
      font-size: 11px;
      color: var(--text-secondary);
    }
    /* Testimonials */
    .testimonials-grid {
      display: flex;
      flex-direction: column;
      gap: 14px;
    }
    .testimonial-card {
      background: var(--card-bg);
      border: 1px solid var(--border-color);
      border-radius: 18px;
      padding: 22px 20px;
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.04);
    }
    .testimonial-stars {
      color: #F59E0B;
      font-size: 13px;
      letter-spacing: 2px;
      margin-bottom: 10px;
    }
    .testimonial-quote {
      font-size: 14px;
      line-height: 1.55;
      color: var(--text-primary);
      font-style: italic;
      margin-bottom: 16px;
    }
    .testimonial-author-row {
      display: flex;
      align-items: center;
      gap: 12px;
    }
    .testimonial-avatar {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      object-fit: cover;
    }
    .testimonial-avatar-placeholder {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      background: var(--primary);
      color: var(--text-inverse);
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 700;
      font-size: 14px;
    }
    .testimonial-author {
      font-size: 13.5px;
      font-weight: 700;
      color: var(--text-primary);
    }
    .testimonial-role {
      font-size: 11.5px;
      color: var(--text-secondary);
    }
    /* FAQ Accordion */
    .faq-list {
      display: flex;
      flex-direction: column;
      gap: 12px;
    }
    .faq-item {
      background: var(--card-bg);
      border: 1px solid var(--border-color);
      border-radius: 14px;
      padding: 16px 18px;
    }
    .faq-question {
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: 14px;
      font-weight: 700;
      color: var(--text-primary);
    }
    .faq-icon {
      font-size: 16px;
      color: var(--primary);
      font-weight: 600;
      margin-left: 8px;
    }
    .faq-answer {
      margin-top: 10px;
      font-size: 13px;
      line-height: 1.55;
      color: var(--text-secondary);
    }
    /* Gallery */
    .gallery-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 12px;
    }
    .gallery-item {
      border-radius: 14px;
      overflow: hidden;
      height: 140px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
      border: 1px solid var(--border-color);
    }
    .gallery-item img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
    }
    /* Visit / Location */
    .visit-card {
      background: var(--card-bg);
      border-radius: 18px;
      padding: 24px 20px;
      border: 1px solid var(--border-color);
    }
    .visit-row {
      margin-bottom: 14px;
    }
    .visit-label {
      font-size: 11px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.8px;
      color: var(--primary);
      margin-bottom: 3px;
    }
    .visit-val {
      font-size: 14px;
      color: var(--text-primary);
      white-space: pre-line;
    }
    /* CTA Box */
    .cta-box {
      text-align: center;
      padding: 36px 20px;
      background: linear-gradient(135deg, var(--surface), var(--card-bg));
      border-radius: 20px;
      border: 1px solid var(--border-color);
    }
    .cta-title {
      font-size: 22px;
      font-weight: 800;
      margin-bottom: 10px;
    }
    .cta-sub {
      font-size: 14px;
      color: var(--text-secondary);
      margin-bottom: 20px;
    }
    /* Footer */
    .footer {
      padding: 32px 20px;
      border-top: 1px solid var(--border-color);
      text-align: center;
      font-size: 12px;
      color: var(--text-secondary);
    }
    .footer-links {
      display: flex;
      justify-content: center;
      gap: 16px;
      margin-top: 8px;
    }
    .footer-link {
      color: var(--text-secondary);
      text-decoration: none;
    }
  </style>
</head>
<body>
  <div class="navbar">
    <a href="#" class="brand-logo">${_escape(siteName)}</a>
    <div class="nav-links">
      ${navItems.take(2).map((item) => '<a href="#" class="nav-btn">${_escape(item["label"] ?? "Visit")}</a>').join('')}
      <span class="menu-icon">☰</span>
    </div>
  </div>

  <main>
    $sectionsHtml
  </main>

  ${hasFooterSection ? '' : '''<footer class="footer">
    <p>© ${DateTime.now().year} ${_escape(siteName)}. All rights reserved.</p>
    <div class="footer-links">
      <a href="#" class="footer-link">Privacy</a>
      <a href="#" class="footer-link">Terms</a>
      <a href="#" class="footer-link">Contact</a>
    </div>
  </footer>'''}
</body>
</html>''';
  }

  static String _renderSection(
    Map<String, dynamic> section,
    String primaryColor,
    String surfaceColor,
  ) {
    final comp = section['component'] as String? ?? 'hero';
    final props = section['props'] as Map<String, dynamic>? ?? {};
    final styles = section['styles'] as Map<String, dynamic>? ?? {};
    final isSurface = styles['background'] == 'surface';
    final wrapClass = isSurface ? 'section section-surface' : 'section';

    switch (comp) {
      case 'hero':
        final badge = props['badge'] as String? ?? '';
        final headline = props['headline'] as String? ?? 'Welcome';
        final subheadline = props['subheadline'] as String? ?? '';
        final ctaText = props['ctaText'] as String? ?? 'Get Started';
        final secondaryCtaText = props['secondaryCtaText'] as String? ?? '';
        final imageObj = props['image'];
        final imgSrc = imageObj is Map ? imageObj['src'] : props['imageSrc'];

        return '''<section class="$wrapClass">
  <div class="container">
    ${badge.isNotEmpty ? '<div class="hero-badge">${_escape(badge)}</div>' : ''}
    <h1 class="hero-title">${_escape(headline).replaceAll('\n', '<br>')}</h1>
    ${subheadline.isNotEmpty ? '<p class="hero-sub">${_escape(subheadline)}</p>' : ''}
    <div class="hero-cta-group">
      <a href="#" class="btn-pill-primary">${_escape(ctaText)}</a>
      ${secondaryCtaText.isNotEmpty ? '<a href="#" class="btn-pill-secondary">${_escape(secondaryCtaText)}</a>' : ''}
    </div>
    ${imgSrc != null && imgSrc.toString().isNotEmpty ? '<div class="hero-image-wrap"><img src="${_escape(imgSrc.toString())}" alt="Hero Image"></div>' : ''}
  </div>
</section>''';

      case 'products':
      case 'store':
      case 'product_grid':
      case 'pricing':
      case 'pricing_grid':
        final title = props['title'] as String? ?? props['headline'] as String? ?? 'Products';
        final subtitle = props['subtitle'] as String? ?? props['subheadline'] as String? ?? '';
        final rawItems = (props['items'] ?? props['products'] ?? props['plans']) as List? ?? [];
        final items = rawItems.map((e) {
          if (e is Map) {
            return Map<String, dynamic>.from(e);
          }
          return <String, dynamic>{'name': e.toString()};
        }).toList();

        return '''<section class="$wrapClass">
  <div class="container">
    <div class="sec-header">
      <h2 class="sec-title">${_escape(title)}</h2>
      ${subtitle.isNotEmpty ? '<p class="sec-sub">${_escape(subtitle)}</p>' : ''}
    </div>
    <div class="products-grid">
      ${items.map((it) {
          final pName = it['name'] ?? it['title'] ?? 'Product';
          final pPrice = it['price'] ?? it['cost'] ?? '';
          final pDesc = it['description'] ?? it['desc'] ?? '';
          final pImg = it['image'] ?? it['image_url'] ?? it['img'] ?? it['src'] ?? '';
          return '''<div class="product-card">
        ${pImg.toString().isNotEmpty ? '<img src="${_escape(pImg.toString())}" class="product-thumb" alt="${_escape(pName.toString())}">' : ''}
        <div class="product-info">
          <div class="product-name">${_escape(pName.toString())}</div>
          ${pPrice.toString().isNotEmpty ? '<div class="product-price">${_escape(pPrice.toString())}</div>' : ''}
          ${pDesc.toString().isNotEmpty ? '<div class="product-desc">${_escape(pDesc.toString())}</div>' : ''}
        </div>
      </div>''';
        }).join('\n')}
    </div>
  </div>
</section>''';

      case 'about':
      case 'story':
        final title = props['title'] as String? ?? 'Our Story';
        final subtitle = props['subtitle'] as String? ?? '';
        final body = props['body'] as String? ?? '';
        final image = props['image'] as String? ?? '';

        return '''<section class="$wrapClass">
  <div class="container">
    <div class="story-card">
      ${image.isNotEmpty ? '<img src="${_escape(image)}" alt="Story">' : ''}
      <div class="story-content">
        <h2 class="sec-title" style="text-align: left; margin-bottom: 8px;">${_escape(title)}</h2>
        ${subtitle.isNotEmpty ? '<div class="story-quote">"${_escape(subtitle)}"</div>' : ''}
        <div class="story-body">${_escape(body)}</div>
      </div>
    </div>
  </div>
</section>''';

      case 'features':
        final title = props['title'] as String? ?? 'Features';
        final subtitle = props['subtitle'] as String? ?? '';
        final items = (props['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        return '''<section class="$wrapClass">
  <div class="container">
    <div class="sec-header">
      <h2 class="sec-title">${_escape(title)}</h2>
      ${subtitle.isNotEmpty ? '<p class="sec-sub">${_escape(subtitle)}</p>' : ''}
    </div>
    ${items.map((it) {
          final fTitle = it['title'] ?? 'Feature';
          final fDesc = it['description'] ?? '';
          final fIcon = it['icon'] ?? '✦';
          return '''<div class="feature-item">
      <div class="feature-icon">$fIcon</div>
      <div class="feature-title">${_escape(fTitle.toString())}</div>
      <div class="feature-desc">${_escape(fDesc.toString())}</div>
    </div>''';
        }).join('\n')}
  </div>
</section>''';

      case 'visit':
        final title = props['title'] as String? ?? 'Visit Us';
        final subtitle = props['subtitle'] as String? ?? '';
        final address = props['address'] as String? ?? '';
        final hours = props['hours'] as String? ?? '';
        final phone = props['phone'] as String? ?? '';
        final ctaText = props['ctaText'] as String? ?? 'Get Directions';

        return '''<section class="$wrapClass">
  <div class="container">
    <div class="sec-header">
      <h2 class="sec-title">${_escape(title)}</h2>
      ${subtitle.isNotEmpty ? '<p class="sec-sub">${_escape(subtitle)}</p>' : ''}
    </div>
    <div class="visit-card">
      ${address.isNotEmpty ? '<div class="visit-row"><div class="visit-label">Address</div><div class="visit-val">${_escape(address)}</div></div>' : ''}
      ${hours.isNotEmpty ? '<div class="visit-row"><div class="visit-label">Hours</div><div class="visit-val">${_escape(hours)}</div></div>' : ''}
      ${phone.isNotEmpty ? '<div class="visit-row"><div class="visit-label">Telephone</div><div class="visit-val">${_escape(phone)}</div></div>' : ''}
      <a href="#" class="btn-pill-primary" style="margin-top: 10px;">${_escape(ctaText)}</a>
    </div>
  </div>
</section>''';

      case 'statistics':
      case 'stats':
        final title = props['title'] as String? ?? props['headline'] as String? ?? '';
        final subtitle = props['subtitle'] as String? ?? props['subheadline'] as String? ?? '';
        final rawMetrics = (props['metrics'] ?? props['items'] ?? props['stats']) as List? ?? [];
        final metrics = rawMetrics.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList();

        return '''<section class="$wrapClass">
  <div class="container">
    ${title.isNotEmpty ? '''<div class="sec-header">
      <h2 class="sec-title">${_escape(title)}</h2>
      ${subtitle.isNotEmpty ? '<p class="sec-sub">${_escape(subtitle)}</p>' : ''}
    </div>''' : ''}
    <div class="stats-grid">
      ${metrics.map((m) {
          final val = m['value'] ?? m['stat'] ?? m['number'] ?? '';
          final label = m['label'] ?? m['title'] ?? '';
          final desc = m['description'] ?? m['desc'] ?? '';
          return '''<div class="stat-card">
        <div class="stat-value">${_escape(val.toString())}</div>
        <div class="stat-label">${_escape(label.toString())}</div>
        ${desc.toString().isNotEmpty ? '<div class="stat-desc">${_escape(desc.toString())}</div>' : ''}
      </div>''';
        }).join('\n')}
    </div>
  </div>
</section>''';

      case 'testimonials':
      case 'reviews':
        final title = props['title'] as String? ?? 'What Our Clients Say';
        final subtitle = props['subtitle'] as String? ?? '';
        final rawItems = (props['items'] ?? props['testimonials'] ?? props['reviews']) as List? ?? [];
        final items = rawItems.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList();

        return '''<section class="$wrapClass">
  <div class="container">
    <div class="sec-header">
      <h2 class="sec-title">${_escape(title)}</h2>
      ${subtitle.isNotEmpty ? '<p class="sec-sub">${_escape(subtitle)}</p>' : ''}
    </div>
    <div class="testimonials-grid">
      ${items.map((t) {
          final quote = t['quote'] ?? t['text'] ?? t['body'] ?? '';
          final author = t['author'] ?? t['name'] ?? '';
          final role = t['role'] ?? t['title'] ?? t['company'] ?? '';
          final avatar = t['avatar'] ?? t['image'] ?? '';
          return '''<div class="testimonial-card">
        <div class="testimonial-stars">★★★★★</div>
        <div class="testimonial-quote">"${_escape(quote.toString())}"</div>
        <div class="testimonial-author-row">
          ${avatar.toString().isNotEmpty ? '<img src="${_escape(avatar.toString())}" class="testimonial-avatar" alt="${_escape(author.toString())}">' : '<div class="testimonial-avatar-placeholder">✦</div>'}
          <div class="testimonial-meta">
            <div class="testimonial-author">${_escape(author.toString())}</div>
            ${role.toString().isNotEmpty ? '<div class="testimonial-role">${_escape(role.toString())}</div>' : ''}
          </div>
        </div>
      </div>''';
        }).join('\n')}
    </div>
  </div>
</section>''';

      case 'faq':
        final title = props['title'] as String? ?? 'Frequently Asked Questions';
        final subtitle = props['subtitle'] as String? ?? '';
        final rawItems = (props['items'] ?? props['faqs'] ?? props['questions']) as List? ?? [];
        final items = rawItems.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList();

        return '''<section class="$wrapClass">
  <div class="container">
    <div class="sec-header">
      <h2 class="sec-title">${_escape(title)}</h2>
      ${subtitle.isNotEmpty ? '<p class="sec-sub">${_escape(subtitle)}</p>' : ''}
    </div>
    <div class="faq-list">
      ${items.map((q) {
          final question = q['question'] ?? q['q'] ?? q['title'] ?? '';
          final answer = q['answer'] ?? q['a'] ?? q['body'] ?? '';
          return '''<div class="faq-item">
        <div class="faq-question">
          <span>${_escape(question.toString())}</span>
          <span class="faq-icon">+</span>
        </div>
        <div class="faq-answer">${_escape(answer.toString())}</div>
      </div>''';
        }).join('\n')}
    </div>
  </div>
</section>''';

      case 'gallery':
        final title = props['title'] as String? ?? '';
        final subtitle = props['subtitle'] as String? ?? '';
        final rawImages = (props['images'] ?? props['items'] ?? props['photos']) as List? ?? [];
        final images = rawImages.map((e) {
          if (e is Map) return Map<String, dynamic>.from(e);
          return <String, dynamic>{'src': e.toString()};
        }).toList();

        return '''<section class="$wrapClass">
  <div class="container">
    ${title.isNotEmpty ? '''<div class="sec-header">
      <h2 class="sec-title">${_escape(title)}</h2>
      ${subtitle.isNotEmpty ? '<p class="sec-sub">${_escape(subtitle)}</p>' : ''}
    </div>''' : ''}
    <div class="gallery-grid">
      ${images.map((img) {
          final src = img['src'] ?? img['url'] ?? img['image'] ?? '';
          final alt = img['alt'] ?? img['caption'] ?? 'Gallery photo';
          return '''<div class="gallery-item">
        <img src="${_escape(src.toString())}" alt="${_escape(alt.toString())}" loading="lazy">
      </div>''';
        }).join('\n')}
    </div>
  </div>
</section>''';

      case 'cta':
        final headline = props['headline'] as String? ?? 'Ready to Begin?';
        final description = props['description'] as String? ?? '';
        final buttonText = props['buttonText'] as String? ?? 'Contact Us';

        return '''<section class="$wrapClass">
  <div class="container">
    <div class="cta-box">
      <h2 class="cta-title">${_escape(headline)}</h2>
      ${description.isNotEmpty ? '<p class="cta-sub">${_escape(description)}</p>' : ''}
      <a href="#" class="btn-pill-primary">${_escape(buttonText)}</a>
    </div>
  </div>
</section>''';

      case 'footer':
        final copyright = props['copyright'] as String? ?? '© 2026 All rights reserved.';
        final links = (props['links'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final linksHtml = links.map((l) => '<a href="#" class="footer-link">${_escape(l["label"]?.toString() ?? "")}</a>').join('');
        return '''<footer class="footer">
  <div class="container">
    <p>${_escape(copyright)}</p>
    ${links.isNotEmpty ? '<div class="footer-links">$linksHtml</div>' : ''}
  </div>
</footer>''';

      default:
        return '';
    }
  }

  static String _escape(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
  }

  static bool _isColorDark(dynamic hex) {
    if (hex == null || hex is! String || hex.isEmpty) return false;
    try {
      final clean = hex.replaceAll('#', '');
      int intVal = 0;
      if (clean.length == 6) {
        intVal = int.parse('FF$clean', radix: 16);
      } else if (clean.length == 8) {
        intVal = int.parse(clean, radix: 16);
      }
      final r = (intVal >> 16) & 0xFF;
      final g = (intVal >> 8) & 0xFF;
      final b = intVal & 0xFF;
      final luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0;
      return luminance < 0.5;
    } catch (_) {
      return false;
    }
  }
}
