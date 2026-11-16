-- Perfil de sessão por jogador: estado dos selos e encontros concluídos.
-- SOMENTE SESSÃO: não há DataStore nesta fase (persistência pendente no GDD).
-- A concessão é idempotente: repetir o mesmo encontro, uma segunda emissão
-- da mesma vitória ou uma nova vitória do mesmo reino devolve "duplicate".
--
-- Contrato confirmado com Ember (sol/ember-combate):
--   Ember.build(parent, onVictory(player, encounterId: string)) -> enter(player): boolean
-- O callback onVictory é criado por Start já no escopo do reino (um por
-- build de reino), então o reino é informado aqui explicitamente e o
-- encounterId — GUID por tentativa gerado no servidor de Ember — serve de
-- deduplicação. Enquanto houver emissões, cada id só concede uma vez.
--
-- Concorrência: nenhuma função aqui produz yield, então cada chamada do
-- servidor é atômica em relação às outras; não há corrida entre jogadores.

local Profile = {}

export type Seal = {
	id: string,
	-- Posição do selo visual no hub (1..4), usada pelo Hub.setSealEarned.
	index: number,
	title: string,
}

-- Reino -> selo. Os demais reinos entram aqui quando definidos no GDD.
local REALM_SEALS: { [string]: Seal } = {
	Ember = {
		id = "Ember",
		index = 1,
		title = "Selo de Ember",
	},
}

export type Session = {
	seals: { [string]: boolean },
	encounters: { [string]: boolean },
	-- Contagem de eventos/vitórias duplicadas ignoradas nesta sessão
	-- (diagnóstico pedido pelo GDD: detectar recompensas duplicadas).
	duplicates: number,
}

local sessions: { [Player]: Session } = {}

-- Registro tolerante a ambiente: Roblox tem warn; o CLI Luau standalone
-- (spec) não o tem, então o diagnóstico cai no print quando indisponível.
local function logDuplicate(message: string)
	if warn then
		warn(message)
	else
		print(message)
	end
end

local function getSession(player: Player): Session
	local session = sessions[player]
	if not session then
		session = { seals = {}, encounters = {}, duplicates = 0 }
		sessions[player] = session
	end
	return session
end

function Profile.sealForRealm(realmId: string): Seal?
	return REALM_SEALS[realmId]
end

-- Registra a vitória validada pelo servidor do reino e concede o selo
-- correspondente uma única vez por sessão.
-- Retorna "granted" | "duplicate" | "unknown" e, quando resolvido, o selo.
function Profile.recordVictory(player: Player, realmId: string, encounterId: string): ("granted" | "duplicate" | "unknown", Seal?)
	local seal = REALM_SEALS[realmId]
	if not seal then
		return "unknown", nil
	end
	local session = getSession(player)
	if type(encounterId) == "string" and encounterId ~= "" then
		if session.encounters[encounterId] then
			session.duplicates += 1
			logDuplicate(("[Profile] evento duplicado ignorado: %s / %s (total %d)")
				:format(player.Name, encounterId, session.duplicates))
			return "duplicate", seal
		end
		session.encounters[encounterId] = true
	end
	if session.seals[seal.id] then
		session.duplicates += 1
		logDuplicate(("[Profile] selo já concedido nesta sessão: %s / %s (total %d)")
			:format(player.Name, seal.id, session.duplicates))
		return "duplicate", seal
	end
	session.seals[seal.id] = true
	return "granted", seal
end

-- Concessão direta (para testes ou recompensas futuras). Idempotente.
function Profile.grantSeal(player: Player, seal: Seal): boolean
	local session = getSession(player)
	if session.seals[seal.id] then
		return false
	end
	session.seals[seal.id] = true
	return true
end

function Profile.hasSeal(player: Player, sealId: string): boolean
	local session = sessions[player]
	return session ~= nil and session.seals[sealId] == true
end

function Profile.clearSession(player: Player)
	sessions[player] = nil
end

return Profile
