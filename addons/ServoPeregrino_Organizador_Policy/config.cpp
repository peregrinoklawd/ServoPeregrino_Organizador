class CfgPatches
{
    class ServoPeregrino_Organizador_Policy
    {
        name = "SP_ORG - Policy (P1 Core Candidate)";
        author = "Claudio Malta Telhada";
        requiredVersion = 2.18;
        requiredAddons[] = {"A3_Functions_F", "ServoPeregrino_Organizador_Nexus"};
        units[] = {};
        weapons[] = {};
        version = "0.1.0";
    };
};
class CfgFunctions
{
    class ServoPeregrino_Organizador_Policy
    {
        tag = "ServoPeregrino_Organizador_Policy";
        class Core
        {
            file = "\ServoPeregrino_Organizador_Policy\functions\core";
            class isValidClassname {};
            class validateExport {};
            class createContext {};
            class evaluate {};
            class snapshot {};
        };
        class Lifecycle
        {
            file = "\ServoPeregrino_Organizador_Policy\functions\lifecycle";
            class initialize { preInit = 1; };
        };
    };
};
/* Do not declare CfgRemoteExec global mode/jip; loading/authority are P2/P6. */
