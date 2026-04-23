<?php
// ============================================================
//  export-data.php — Export database to static JSON files
//  Run ONCE to create offline data for APK
// ============================================================

require_once __DIR__ . '/config/db.php';

$pdo = getDB();
$dataDir = __DIR__ . '/data';
if (!is_dir($dataDir)) mkdir($dataDir, 0777, true);

echo "=== GéoCollège Data Export ===\n\n";

// ═══════════════════════════════════════════
// 1. EXPORT FORMES (same logic as api/formes.php)
// ═══════════════════════════════════════════
$stmt = $pdo->query("SELECT f.id, f.slug, f.nom, f.categorie, f.niveau,
                            f.description, f.proprietes, f.svg_viewbox,
                            f.svg_elements, f.image_url
                     FROM vue_formes f WHERE f.actif = 1
                     ORDER BY f.categorie, f.niveau, f.nom");
$formes = $stmt->fetchAll();

$stmtFormules = $pdo->prepare(
    "SELECT type_formule AS type, formule, latex,
            exemple_vals, exemple_res, exemple_note
     FROM formules WHERE forme_id = :id ORDER BY ordre"
);
$stmtTheos = $pdo->prepare(
    "SELECT t.slug, t.nom
     FROM theoremes t JOIN forme_theoreme ft ON ft.theoreme_id = t.id
     WHERE ft.forme_id = :id"
);

$vars = [
    'triangle-rectangle'   => ['b' => 'base (cm)', 'h' => 'hauteur (cm)'],
    'triangle-equilateral' => ['a' => 'côté (cm)', 'h' => 'hauteur (cm)'],
    'triangle-isocele'     => ['a' => 'côté principal (cm)', 'b' => 'base (cm)', 'h' => 'hauteur (cm)'],
    'triangle-quelconque'  => ['b' => 'base (cm)', 'h' => 'hauteur (cm)'],
    'carre'                => ['c' => 'côté (cm)'],
    'rectangle'            => ['L' => 'longueur (cm)', 'l' => 'largeur (cm)'],
    'parallelogramme'      => ['b' => 'base (cm)', 'h' => 'hauteur (cm)'],
    'losange'              => ['d1' => 'grande diagonale (cm)', 'd2' => 'petite diagonale (cm)', 'c' => 'côté (cm)'],
    'trapeze'              => ['B' => 'grande base (cm)', 'b' => 'petite base (cm)', 'h' => 'hauteur (cm)'],
    'cercle'               => ['r' => 'rayon (cm)'],
    'disque'               => ['r' => 'rayon (cm)'],
];

foreach ($formes as &$forme) {
    $forme['proprietes'] = json_decode($forme['proprietes'] ?? '[]', true) ?? [];
    
    $stmtFormules->execute([':id' => $forme['id']]);
    $formules = $stmtFormules->fetchAll();
    $forme['formules'] = array_map(function ($fm) {
        $exemple = [];
        if ($fm['exemple_vals']) {
            $vals = json_decode($fm['exemple_vals'], true);
            if ($vals) $exemple = $vals;
        }
        if ($fm['exemple_res'])  $exemple['resultat'] = $fm['exemple_res'];
        if ($fm['exemple_note']) $exemple['note']     = $fm['exemple_note'];
        return [
            'type'    => $fm['type'],
            'formule' => $fm['formule'],
            'latex'   => $fm['latex'],
            'exemple' => $exemple ?: new stdClass(),
        ];
    }, $formules);

    $stmtTheos->execute([':id' => $forme['id']]);
    $theos = $stmtTheos->fetchAll();
    $forme['theoremes_lies'] = array_column($theos, 'slug');
    $forme['svg'] = ['viewBox' => $forme['svg_viewbox'], 'elements' => $forme['svg_elements'] ?? ''];
    $forme['variables'] = $vars[$forme['slug']] ?? [];
    
    // Keep id for reference, remove internal fields
    unset($forme['svg_viewbox'], $forme['svg_elements']);
}
unset($forme);

file_put_contents("$dataDir/formes.json", json_encode($formes, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT));
echo "✅ formes.json — " . count($formes) . " formes exported\n";

// ═══════════════════════════════════════════
// 2. EXPORT EXERCICES (WITH answers for offline verification)
// ═══════════════════════════════════════════
$stmt = $pdo->query("SELECT e.id, e.titre, e.enonce, e.valeurs, e.type_calcul,
                            e.reponse, e.tolerance, e.unite, e.explication,
                            e.etapes, e.niveau, e.difficulte,
                            e.forme_slug, e.forme_nom, e.svg_viewbox,
                            e.svg_elements, e.categorie
                     FROM vue_exercices e WHERE e.actif = 1
                     ORDER BY e.niveau, e.difficulte, e.id");
$exercices = $stmt->fetchAll();

foreach ($exercices as &$ex) {
    $ex['valeurs']   = json_decode($ex['valeurs'] ?? '{}', true) ?? [];
    $ex['etapes']    = json_decode($ex['etapes'] ?? '[]', true) ?? [];
    $ex['reponse']   = (float)$ex['reponse'];
    $ex['tolerance'] = (float)$ex['tolerance'];
    $ex['svg'] = ['viewBox' => $ex['svg_viewbox'], 'elements' => $ex['svg_elements'] ?? ''];
    unset($ex['svg_viewbox'], $ex['svg_elements']);
}
unset($ex);

file_put_contents("$dataDir/exercices.json", json_encode($exercices, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT));
echo "✅ exercices.json — " . count($exercices) . " exercices exported (with answers)\n";

// ═══════════════════════════════════════════
// 3. EXPORT THEOREMES
// ═══════════════════════════════════════════
$stmt = $pdo->query("SELECT id, slug, nom, niveau, categorie,
                            enonce, `condition`, formule, formes_liees
                     FROM theoremes WHERE actif = 1
                     ORDER BY niveau, nom");
$theoremes = $stmt->fetchAll();

foreach ($theoremes as &$t) {
    $t['formes_liees'] = json_decode($t['formes_liees'] ?? '[]', true) ?? [];
}
unset($t);

file_put_contents("$dataDir/theoremes.json", json_encode($theoremes, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT));
echo "✅ theoremes.json — " . count($theoremes) . " théorèmes exported\n";

echo "\n=== DONE! All data exported to /data/ folder ===\n";
