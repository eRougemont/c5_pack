<?php

include_once(__DIR__ . '/vendor/autoload.php');

use Psr\Log\{LogLevel};
use Oeuvres\Kit\{Filesys, Log, LoggerCli, Xsl};

if (php_sapi_name() == "cli") C5pack::cli();


class C5pack
{
    /** XSLTProcessors */
    private static $_trans = array();

    private static function help()
    {
        $help = "
      php c5pack.php -f? ../ddr-articles/ddr-espr.xml\n";
        return $help;
    } 
    /**
     * Command line transform
     */
    public static function cli()
    {
        Log::setLogger(new LoggerCli());
        global $argv;
        $shortopts = "";
        $shortopts .= "f"; // force transformation
        $options = getopt($shortopts);
        $count = count($argv); 
        if ($count < 2) exit(self::help());
        $force = isset($options['f']);

        if ($argv[1] == "titles") {
            self::titles();
        }
        for ($i = 1; $i < $count; $i++) {
            $glob = $argv[$i];
            foreach (glob($glob) as $src_file) {
                self::file($src_file, $force);
            }
        }
    }

    public static function file($src_file, $force = false, $doctype = null)
    {

        $fullpath = realpath($src_file);

        if ($doctype != null);
        else if (stripos($src_file, 'corr')) $doctype = 'corr';
        else if (stripos($src_file, 'articles')) $doctype = 'articles';
        else $doctype = 'livres';


        $filename = pathinfo($src_file, PATHINFO_FILENAME);
        if ($doctype == "articles") {
            $bookname = substr($filename, 4);
            $bookpath = "/articles/$bookname";
            $xsl = dirname(__FILE__) . '/_engine/c5-articles.xsl';
            $package = strtr($filename, array('-' => '_'));
        } else if ($doctype == "corr") {
            $bookname = substr($filename, 9);
            $bookpath = "/correspondances/$bookname";
            $xsl = dirname(__FILE__) . '/_engine/c5-corr.xsl';
            $package = strtr($filename, array('-' => '_'));
        } else if ($doctype == "livres") {
            $bookname = strtok($filename, '_');
            $bookpath = "/livres/$bookname";
            $xsl = dirname(__FILE__) . '/_engine/c5-chapitres.xsl';
            $date = substr($filename, 3, 4);
            $package = strtok($filename, '_');
        }
        $dst_dir = dirname(__FILE__) . '/' . $package;
        if (!file_exists($dst_dir)) Filesys::mkdir($dst_dir);
        else if ($force);
        else if (filemtime($dst_dir . '/content.xml') > filemtime($src_file)) return;
        // say that folder has been modified
        touch($dst_dir);
        echo $src_file . "\n";

        $dom = Xsl::load($src_file);
        $title = "";
        $xpath = new DOMXpath($dom);
        $xpath->registerNamespace('tei', "http://www.tei-c.org/ns/1.0");
        $nl = $xpath->query("//tei:title[1]");
        if ($nl->length) $title .= $nl->item(0)->textContent;


        $php = file_get_contents(dirname(__FILE__) . "/_engine/controller.php");
        $version = date("y.m.d");
        $php = str_replace(
            array('%Class%', '%handle%', '%version%', '%bookpath%', '%title%'),
            array(ucfirst(strtr($package, array('_' => ''))), $package, $version, $bookpath, str_replace("'", "’", $title)),
            $php,
        );
        file_put_contents($dst_dir . '/controller.php', $php);


        $xml = Xsl::transformToXml(
            $xsl,
            $dom,
            array('package' => $package, 'bookpath' => $bookpath)
        );
        // contenus de page à encadrer de CDATA 
        $xml = str_replace(array("<content>", "</content>"), array("<content><![CDATA[", "]]></content>"), $xml);
        file_put_contents($dst_dir . '/content.xml', $xml);

        if ($doctype == "livres") {
            $dstfile = $dst_dir . "/" . $package . '_toc.html';
            $html = Xsl::transformToXml(
                dirname(__FILE__) . '/_engine/c5-toc.xsl',
                $dom,
                array('bookname' => $bookname)
            );
            // supprimer première et dernière ligne (conteneur)
            $html = trim($html);
            $html = substr($html, strpos($html, "\n") + 1);
            $html = substr($html, 0, strrpos($html, "\n"));
            file_put_contents($dstfile, $html);
        }
    }

    public static function titles($glob = "ddr19*/content.xml")
    {
        foreach (glob($glob) as $srcfile) {
            $text = file_get_contents($srcfile);
            preg_match_all('@<attributekey handle="meta_title">\s*<value>(.*)</value>@', $text, $matches);
            echo "\n";
            echo implode("\n", $matches[1]);
            echo "\n";
        }
    }
}
