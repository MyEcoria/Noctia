/** Where `/noctia:models` stores the agent models, relative to the project root. */
export const MODELS_FILE = '.noctia/models'

/** Where `/noctia:effort` stores the agent effort levels, relative to the project root. */
export const EFFORT_FILE = '.noctia/effort'

/**
 * # Parse the choices
 * ## Args
 * - text: content of `.noctia/models` or `.noctia/effort`, one `agent=value` per line
 * ## Returns
 * The choices by agent name. Malformed lines are dropped, the last line of an agent wins.
 * ## Example
 * parseChoices('reader=haiku\ndeveloper=sonnet') // { reader: 'haiku', developer: 'sonnet' }
 */
export const parseChoices = (text: string): Record<string, string> => {
  const choices: Record<string, string> = {}
  for (const line of text.split('\n')) {
    const match = /^([a-z-]+)=([a-z]+)$/.exec(line.trim())
    if (match) choices[match[1]] = match[2]
  }
  return choices
}

/**
 * # Value chosen for an agent
 * ## Args
 * - type: resolved subagent type, possibly prefixed by its plugin (`noctia:reader`)
 * - choices: the parsed choices
 * ## Returns
 * The chosen value, or undefined when the user chose nothing for this agent.
 * ## Example
 * choiceFor('noctia:reader', { reader: 'haiku' }) // 'haiku'
 */
export const choiceFor = (type: string, choices: Record<string, string>): string | undefined =>
  choices[type.split(':').pop() ?? type]
