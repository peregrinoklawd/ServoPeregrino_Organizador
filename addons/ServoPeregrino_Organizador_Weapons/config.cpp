#include "script_version.hpp"
class CfgPatches {
 class ServoPeregrino_Organizador_Weapons {
  name="SP_ORG - Weapons";
  author="Claudio Malta Telhada";
  requiredVersion=2.18;
  requiredAddons[]={"A3_Functions_F","ServoPeregrino_Organizador_Nexus"};
  units[]={}; weapons[]={};
  version=SERVO_PEREGRINO_ORGANIZADOR_WEAPONS_SEMANTIC_VERSION;
 };
};
class CfgFunctions {
 class ServoPeregrino_Organizador_Weapons {
  tag="ServoPeregrino_Organizador_Weapons";
  class Domain {
   file="\ServoPeregrino_Organizador_Weapons\functions\domain";
   class captureWeaponConfiguration {};
   class compareWeaponConfigurations {};
   class configurationFromWeaponArray {};
   class createWeaponConfiguration {};
   class deepCopy {};
   class getConfigurationFingerprint {};
   class isValidIdentityToken {};
   class normalizeWeaponConfiguration {};
   class validateWeaponConfigurationSemantic {};
   class validateWeaponConfigurationStructural {};
   class validateWeaponInstance {};
  };
  class Identity {
   file="\ServoPeregrino_Organizador_Weapons\functions\identity";
   class createWeaponInstance {};
   class getIdentityDiagnostics {};
   class getWeaponInstance {};
   class initializeAuthority {};
   class inspectWeaponCarrier {};
   class updateWeaponInstanceConfiguration {};
  };
  class Integration {
   file="\ServoPeregrino_Organizador_Weapons\functions\integration";
   class validateNexus {};
  };
  class Lifecycle {
   file="\ServoPeregrino_Organizador_Weapons\functions\lifecycle";
   class getBuildInfo {};
   class initialize {preInit=1; postInit=1;};
  };
  class Runtime {
   file="\ServoPeregrino_Organizador_Weapons\functions\runtime";
   class getRuntimeStatus {};
  };
  class Tests {
   file="\ServoPeregrino_Organizador_Weapons\functions\tests";
   class clientReceiveLabResult {};
   class installLabActions {};
   class serverHandleLabRequest {};
  };
 };
};
class CfgRemoteExec {
 class Functions {
  mode=1; jip=0;
  class ServoPeregrino_Organizador_Weapons_fnc_serverHandleLabRequest {allowedTargets=2; jip=0;};
  class ServoPeregrino_Organizador_Weapons_fnc_clientReceiveLabResult {allowedTargets=0; jip=0;};
 };
};
