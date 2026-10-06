#include "script_version.hpp"
#include "ui\shared_controls.hpp"

class CfgPatches
{
    class ServoPeregrino_Organizador_UICommon
    {
        name = "SP_ORG — UICommon";
        author = "Claudio Malta Telhada";
        requiredVersion = 2.18;
        requiredAddons[] = {"A3_Functions_F", "ServoPeregrino_Organizador_Nexus"};
        units[] = {};
        weapons[] = {};
        version = SERVO_PEREGRINO_ORGANIZADOR_UICOMMON_SEMANTIC_VERSION;
    };
};

class CfgFunctions
{
    class ServoPeregrino_Organizador_UICommon
    {
        tag = "ServoPeregrino_Organizador_UICommon";

        class Lifecycle
        {
            file = "\ServoPeregrino_Organizador_UICommon\functions\lifecycle";
            class initialize { preInit = 1; };
            class getBuildInfo {};
        };

        class Runtime
        {
            file = "\ServoPeregrino_Organizador_UICommon\functions\runtime";
            class getRuntimeStatus {};
        };

        class Theme
        {
            file = "\ServoPeregrino_Organizador_UICommon\functions\theme";
            class getThemeTokens {};
        };

        class Lists
        {
            file = "\ServoPeregrino_Organizador_UICommon\functions\lists";
            class clampVirtualOffset {};
            class getVirtualWindow {};
            class getVirtualScrollState {};
            class syncVirtualSlider {};
        };

        class Geometry
        {
            file = "\ServoPeregrino_Organizador_UICommon\functions\geometry";
            class pointInRect {};
            class applyResponsiveControlLayout {};
        };

        class Text
        {
            file = "\ServoPeregrino_Organizador_UICommon\functions\text";
            class escapeStructuredText {};
        };

        class Footer
        {
            file = "\ServoPeregrino_Organizador_UICommon\functions\footer";
            class buildFooterBandStructuredText {};
            class renderFooter {};
        };

        class Tests
        {
            file = "\ServoPeregrino_Organizador_UICommon\functions\tests";
            class runFoundationTests {};
        };
    };
};
