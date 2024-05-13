<?php

namespace Concrete\Package\C5tei\Controller\SinglePage\Dashboard;

use Concrete\Core\Backup\ContentImporter;
use Concrete\Core\Page\Controller\DashboardPageController;

use Oeuvres\Kit\{Log, Xt};
use Oeuvres\Kit\Logger\{LoggerMem};
use Psr\Log\LogLevel;




class C5tei extends DashboardPageController
{
    public $repos = [
        'ddr_livres'=>[],
        'ddr_articles'=> [], 
        'ddr_inedits'=>[],
        'ddr_correspondances'=>[],
    ];
    /** A token fo gh */
    private $ghtok;
    /** absolute file pack for xsl dir */
    private $xsl_dir;
    /** Asimple mem logger to get error messages */
    private $logger;


    public function on_start()
    {
        $this->logger = new LoggerMem(LogLevel::DEBUG);
        Log::setLogger($this->logger);
        Log::info("start");

        $this->xsl_dir = dirname(__DIR__, 3) . '/src/';
        $config_file = dirname(__DIR__, 3) . '/config.php';
        if (file_exists($config_file)) {
            $config = include($config_file);
            if (isset($config['ghtok'])) $this->ghtok = $config['ghtok'];
        }

        $this->MyTheme();
        // page recréée à chaque, l’info est à recharger
        $this->gh_ls();
        $this->set('repos', $this->repos);
    }

    public function view()
    {
        // get list of files
        // one day, give the list of last modified url
        // $this->set('message', 'Charger un fichier XML TEI');
        $this->set('message', $this->logger->messages());
    }

    public function load()
    {
        // 
        // no reload ? should be OK ?
        $this->set('repos', $this->repos);
        $repo = $this->request->query->get('repo');
        $file = $this->request->query->get($repo);
        // be careful of "master", branch may change
        $url = sprintf("https://raw.githubusercontent.com/eRougemont/%s/master/%s", $repo, $file);
        Log::info($url);
        $xml = self::curl_get_contents($url);

        $this->set('xml', $xml);
        $this->cif($repo, $file, $xml);
        // export trace if any
        $this->set('message', $this->logger->messages());
    }


    /**
     * Get the cif from a $tei string
     */
    public function cif($repo, $file, $xml)
    {

        $filename = pathinfo($file, PATHINFO_FILENAME);

        if ($repo == "ddr_inedits") {
            $bookname = $filename;
            $bookpath = "/inedits/$bookname";
            $xsl = 'c5_articles.xsl';
        }
        else if ($repo == "ddr_articles") {
            $bookname = substr($filename, 4);
            $bookpath = "/articles/$bookname";
            $xsl = 'c5_articles.xsl';
        }
        else if ($repo == "ddr_correspondances") {
            $bookname = substr($filename, 9);
            $bookpath = "/correspondances/$bookname";
            $xsl = 'c5_correspondances.xsl';
        }
        else if ($repo == "ddr_livres") {
            $bookname = strtok($filename, '_');
            $bookpath = "/livres/$bookname";
            $xsl = 'c5_livres.xsl';
            $date = substr($filename, 3, 4);
        }
        // 
        $bookPage = \Page::getByPath($bookpath);
        if($bookPage->isError()) {
            throw new \Exception('Avant de charger ces textes, une page de couverture est nécessaire pour le chemin : '.$bookpath);
        }

        $this->set('bookpath', $bookpath);
        $dom = Xt::loadXml($xml);
        if ($dom === null) {
            Log::info("Erreur XML dans le fichier ?");
            return;
        }
        /*
        $title = "";
        $xpath = new DOMXpath($dom);
        $xpath->registerNamespace('tei', "http://www.tei-c.org/ns/1.0");
        $nl = $xpath->query("//tei:title[1]");
        if ($nl->length) $title .= $nl->item(0)->textContent;
        */


        $cif = Xt::transformToXml(
            $this->xsl_dir . $xsl,
            $dom,
            array('package' => "c5tei", 'bookpath' => $bookpath)
        );
        Log::info("Transformé");
        // contenus de page à encadrer de CDATA 
        $cif = str_replace(array("<content>", "</content>"), array("<content><![CDATA[", "]]></content>"), $cif);
        // avant d’inmporter, supprimer les pages existantes 
        $pl = new \Concrete\Core\Page\PageList();
        $pl->filterByPath($bookpath, true); // !!! true = do not delete parent
        $pages = $pl->get();
        foreach ($pages as $page) {
            $page->delete();
        }
        Log::info("Nettoyé");
        // now load the $cif ?
        $ci = new ContentImporter();
        $ci->importContentString($cif);
        // specific design with toc
        if ($repo == "ddr_livres") {
            $bookPage = \Page::getByPath($bookpath);
            $toc_html = Xt::transformToXml(
                $this->xsl_dir . 'c5_toc.xsl',
                $dom,
                array('bookname' => $bookname)
            );
            // supprimer première et dernière ligne (conteneur)
            $toc_html = trim($toc_html);
            $toc_html = substr($toc_html, strpos($toc_html, "\n") + 1);
            $toc_html = substr($toc_html, 0, strrpos($toc_html, "\n"));
            $data = array();
            $data['content'] = $toc_html;
            $blocks = $bookPage->getBlocks('livre_sommaire');
            $count = count($blocks);
            for ($i = 1; $i < $count; $i++) { // delete too much blocks
                $blocks[$i]->delete();
            }
            if ($count == 0) {
                $bt = \BlockType::getByHandle('content');
                $bookPage->addBlock($bt, 'livre_sommaire', $data);
            }
            else {
                $blocks[0]->update($data);
            }
        }
        Log::info("Chargé");
    }


    /**
     * List files in repos
     */
    public function gh_ls()
    {
        // be careful to branch in future
        $furl = "https://api.github.com/repos/eRougemont/%s/git/trees/master";
        foreach ($this->repos as $rep => $v) {
            $url = sprintf($furl, $rep);
            $json = self::curl_get_contents($url);
            if (!$json) {
                Log::error('ERREUR pour le développeur, rien dans “$url”');
                return;
            }
            $tree = json_decode($json, true);
            if (!isset($tree['tree'])) {
                Log::error("ERREUR pour le développeur, $url pas de tree dans $json " . print_r($tree, true));
                return;
            }
            foreach ($tree['tree'] as $item) {
                if (!isset($item['path'])) {
                    Log::error("Erreur pour le développeur, $url pas de path ".print_r($tree, true));
                    return;
                }
                $ext = pathinfo($item['path'], PATHINFO_EXTENSION);
                if ($ext != 'xml') continue;
                $this->repos[$rep][] = $item['path'];
            }
        }

    }

    function curl_get_contents($url)
    {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.1.2) Gecko/20090729 Firefox/3.5.2 GTB5');

        $header = [];
        if ($this->ghtok) $headers[] = "Authorization: Bearer " . $this->ghtok;
        $headers[] = "Accept: application/vnd.github+json";
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

        // return content as var
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        $contents = curl_exec($ch);
        curl_close($ch);

        if ($contents) return $contents;
        else return FALSE;
    }

    public function MyTheme()
    {
        $this->requireAsset('css', 'c5tei_dash');
        $this->requireAsset('javascript', 'c5tei_dash');
    }
}
