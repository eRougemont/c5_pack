<?php
 
namespace Concrete\Package\C5tei;

use Page;

use Concrete\Core\Package\Package;
use \Concrete\Core\Page\Single as SinglePage;

use Concrete\Core\Asset\Asset;
use Concrete\Core\Asset\AssetList;
use Concrete\Core\Package\PackageService;
use Concrete\Core\Database\EntityManager\Provider\ProviderAggregateInterface;
use Concrete\Core\Database\EntityManager\Provider\StandardPackageProvider;


class Controller extends Package 
{
    protected $pkgHandle = 'c5tei';
    protected $appVersionRequired = '8.3.2';
    protected $pkgVersion = '0.0.5';
    protected $pkgAutoloaderRegistries = [
        'vendor/oeuvres/kit/src' => '\Oeuvres\Kit'
    ];
    
    public function getPackageDescription() 
    {
        return t('TEI for Concrete5');
    }
    
    public function getPackageName() 
    {
        return t('TEI');
    }

    public function install() 
    {
        $pkg = parent::install();
        //install the dashboard single page
        $path = '/dashboard/c5tei';
        $title = 'TEI, chargement';
        $desc = 'Chargement de fichiers TEI dans Concrete5';
        $SinglePage = SinglePage::add($path, $pkg);
        $SinglePage->Update(array('cName'=>$title, 'cDescription'=>$desc));
    }

    public function upgrade()
    {
        $pkg = Package::getByHandle($this->pkgHandle);
        parent::upgrade();
    }
 
    public function uninstall()
    {
        parent::uninstall();
    }

    /*
    public function getEntityManagerProvider()
    {
        $provider = new StandardPackageProvider($this->app, $this, [
            'src/Erougemont' => 'Erougemont'
        ]);
        return $provider;
    }
    */
    

    public function on_start()
    {
        $al = AssetList::getInstance();
        $al->register('javascript', 'c5tei_dash', 'theme/c5tei_dash.js', array('version' => '1', 'position' => Asset::ASSET_POSITION_FOOTER, 'minify' => false, 'combine' => false), $this);
        $al->register('css', 'c5tei_dash', 'theme/c5tei_dash.css', array('version' => '1', 'position' => Asset::ASSET_POSITION_HEADER, 'minify' => false, 'combine' => false), $this);
    }
    

}
