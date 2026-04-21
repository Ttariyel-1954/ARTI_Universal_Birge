-- ═══════════════════════════════════════════════════════════════
-- SEED 01 — Reference məlumatlar
-- ═══════════════════════════════════════════════════════════════

-- ═══ ROLES ═══
INSERT INTO core.roles (code, name, description, is_system) VALUES
  ('super_admin', 'Super Administrator', 'Bütün hüquqlar', TRUE),
  ('admin', 'Administrator', 'Sistem idarəsi', TRUE),
  ('manager', 'Layihə meneceri', 'Layihə idarəsi', FALSE),
  ('inspector', 'Müfəttiş', 'Monitorinq və nəzarət', FALSE),
  ('contractor', 'Podratçı nümayəndəsi', 'Öz layihələrini görür', FALSE),
  ('viewer', 'Baxış rejimi', 'Yalnız oxuma', FALSE)
ON CONFLICT (code) DO NOTHING;

-- ═══ DEPARTMENTS ═══
INSERT INTO core.departments (code, name) VALUES
  ('HQ', 'Mərkəzi idarə'),
  ('PROJ', 'Layihələr şöbəsi'),
  ('FIN', 'Maliyyə şöbəsi'),
  ('INSP', 'Nəzarət şöbəsi')
ON CONFLICT (code) DO NOTHING;

-- ═══ OBJECT TYPES ═══
INSERT INTO construction.object_types (code, name_az, icon) VALUES
  ('school', 'Məktəb', '🏫'),
  ('lyceum', 'Lisey', '🎓'),
  ('gymnasium', 'Gimnaziya', '📚'),
  ('kindergarten', 'Uşaq bağçası', '🧸'),
  ('sport_hall', 'İdman zalı', '⚽'),
  ('admin', 'İnzibati bina', '🏛️'),
  ('clinic', 'Poliklinika', '🏥'),
  ('library', 'Kitabxana', '📖')
ON CONFLICT (code) DO NOTHING;

-- ═══ AZƏRBAYCAN REGİONLARI (qismən) ═══
INSERT INTO construction.regions (code, name_az, name_en, region_type) VALUES
  ('BA', 'Bakı', 'Baku', 'city'),
  ('GA', 'Gəncə', 'Ganja', 'city'),
  ('SM', 'Sumqayıt', 'Sumgait', 'city'),
  ('ML', 'Mingəçevir', 'Mingachevir', 'city'),
  ('SH', 'Şəki', 'Shaki', 'city'),
  ('LA', 'Lənkəran', 'Lankaran', 'city'),
  ('NA', 'Naxçıvan', 'Nakhchivan', 'city'),
  ('QB', 'Quba', 'Quba', 'district'),
  ('QX', 'Qax', 'Qakh', 'district'),
  ('QZ', 'Qəbələ', 'Gabala', 'district'),
  ('ZQ', 'Zaqatala', 'Zaqatala', 'district'),
  ('AS', 'Astara', 'Astara', 'district'),
  ('MS', 'Masallı', 'Masalli', 'district'),
  ('YV', 'Yevlax', 'Yevlakh', 'district'),
  ('BR', 'Bərdə', 'Barda', 'district'),
  ('AG', 'Ağsu', 'Agsu', 'district'),
  ('IS', 'İsmayıllı', 'Ismayilli', 'district'),
  ('SB', 'Şabran', 'Shabran', 'district'),
  ('KU', 'Kürdəmir', 'Kurdamir', 'district'),
  ('BL', 'Balakən', 'Balakan', 'district')
  -- Tam siyahı 77 rayondur, burada 20-ni göstərdik
ON CONFLICT (code) DO NOTHING;

-- ═══ BUDGET CATEGORIES ═══
INSERT INTO construction.budget_categories (code, name, level) VALUES
  ('FOUND', 'Təməl işləri', 1),
  ('WALL', 'Divar işləri', 1),
  ('ROOF', 'Dam işləri', 1),
  ('FLOOR', 'Döşəmə', 1),
  ('ELEC', 'Elektrik işləri', 1),
  ('PLUMB', 'Santexnika', 1),
  ('PAINT', 'Rəng və bəzək', 1),
  ('DOOR_WIN', 'Qapı-pəncərə', 1),
  ('HEAT', 'İstilik sistemi', 1),
  ('VENT', 'Ventilyasiya', 1)
ON CONFLICT (code) DO NOTHING;

SELECT 'Reference seed məlumatları daxil edildi' AS status;
