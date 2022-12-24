<?php defined('C5_EXECUTE') or die("Access Denied.");

use Concrete\Core\Support\Facade\Url;


/*
$list_views = array('view','updated','removed','success');
$add_views = array('add','edit','save');
*/

?>
<h1>eRougemont, mise à jour de textes TEI</h1>

<!--
<a class="btn btn-primary"
    href="<?php echo Url::to('/dashboard/c5tei', 'load'); ?>" 
><?php echo t('Charger un fichier'); ?></a>
-->


<form action="<?php echo Url::to('/dashboard/c5tei', 'load') ?>" style="display:flex;">

    <div>
    <?php
    // $bookPage = Page::getByPath("/correspondances/corbin");
    echo $form->label('repo', 'Entrepôt');
    $opts = array_merge([''], array_keys($repos));
    $opts = array_combine($opts, $opts);
    echo $form->select(
        'repo', 
        $opts,
        '',
        [
           "onchange" => "let value = this.value; let select = document.getElementById(value); if (!select) return; select.style.display = 'block'; if (this.old) {this.old.style.display = 'none'; } this.old = select;"
        ]
    );
    ?>
    </div>

    <div>
    <?php
    echo $form->label('file', 'ddr_fichier.xml');
    foreach($repos as $id => $list) {
        $opts = array_merge([''], $list);
        $opts = array_combine($opts, $opts);
        echo $form->select(
            $id, 
            $opts, 
            '', 
            [
                'style' => 'display: none'
            ]
        );
    }
    ?>
    </div>

    <?php
    echo $form->submit('submit', 'Submit', '', 'button');
    ?>
</form>

<?php if ($controller->getAction() == 'load') { ?>

    <p>Texte chargé : <?= $url ?></p>
    <textarea style="width: 100%;"><?= $xml ?></textarea>
    <textarea style="width: 100%;"><?= $cif ?></textarea>

<?php } ?>


