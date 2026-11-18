#include <sdktools>
#pragma semicolon 1
#pragma newdecls required

ConVar g_cEnableNoBlood;

// String table indexes, looked up once per map: the temp entity hooks run on every
// bullet impact and blood effect
int g_iParticleEffectNames = INVALID_STRING_TABLE;
int g_iEffectDispatch = INVALID_STRING_TABLE;
int g_iDecalPrecache = INVALID_STRING_TABLE;

public Plugin myinfo = 
{
	name = "NoBlood",
	author = "Bara, IT-KiLLER",
	description = "Hide blood",
	version = "1.0.2",
	url = "https://github.com/IT-KiLLER"
};

public void OnPluginStart()
{
	g_cEnableNoBlood = CreateConVar("sm_blood_disable", "1", "Enable / Disable No Blood", _, true, 0.0, true, 1.0);
	AddTempEntHook("Blood Sprite", TE_OnWorldDecal);
	AddTempEntHook("Entity Decal", TE_OnWorldDecal);
	AddTempEntHook("EffectDispatch", TE_OnEffectDispatch);
	AddTempEntHook("World Decal", TE_OnWorldDecal);
	AddTempEntHook("Impact", TE_OnWorldDecal);
}

public void OnMapStart()
{
	// The string tables are created again for each map
	g_iParticleEffectNames = INVALID_STRING_TABLE;
	g_iEffectDispatch = INVALID_STRING_TABLE;
	g_iDecalPrecache = INVALID_STRING_TABLE;
}

public Action TE_OnEffectDispatch(const char[] te_name, const int[] Players, int numClients, float delay)
{
	if (!g_cEnableNoBlood.BoolValue) return Plugin_Continue;

	int iEffectIndex = TE_ReadNum("m_iEffectName");
	int nHitBox = TE_ReadNum("m_nHitBox");
	char sEffectName[64];

	GetEffectName(iEffectIndex, sEffectName, sizeof(sEffectName));

	if (StrEqual(sEffectName, "csblood")|| StrEqual(sEffectName, "Impact"))
	{	
		return Plugin_Handled;
	}

	if (StrEqual(sEffectName, "ParticleEffect"))
	{
		char sParticleEffectName[64];
		GetParticleEffectName(nHitBox, sParticleEffectName, sizeof(sParticleEffectName));
		if(StrEqual(sParticleEffectName, "impact_helmet_headshot"))
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action TE_OnWorldDecal(const char[] te_name, const int[] Players, int numClients, float delay)
{
	if (!g_cEnableNoBlood.BoolValue) return Plugin_Continue;

	float vecOrigin[3];
	int nIndex = TE_ReadNum("m_nIndex");
	char sDecalName[64];

	TE_ReadVector("m_vecOrigin", vecOrigin);
	GetDecalName(nIndex, sDecalName, sizeof(sDecalName));

	if (StrContains(sDecalName, "decals/blood") == 0 && StrContains(sDecalName, "_subrect") != -1)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

stock int GetParticleEffectName(int index, char[] sEffectName, int maxlen)
{
	if (g_iParticleEffectNames == INVALID_STRING_TABLE)
	{
		g_iParticleEffectNames = FindStringTable("ParticleEffectNames");
	}

	return ReadStringTable(g_iParticleEffectNames, index, sEffectName, maxlen);
}

stock int GetEffectName(int index, char[] sEffectName, int maxlen)
{
	if (g_iEffectDispatch == INVALID_STRING_TABLE)
	{
		g_iEffectDispatch = FindStringTable("EffectDispatch");
	}

	return ReadStringTable(g_iEffectDispatch, index, sEffectName, maxlen);
}

stock int GetDecalName(int index, char[] sDecalName, int maxlen)
{
	if (g_iDecalPrecache == INVALID_STRING_TABLE)
	{
		g_iDecalPrecache = FindStringTable("decalprecache");
	}

	return ReadStringTable(g_iDecalPrecache, index, sDecalName, maxlen);
}