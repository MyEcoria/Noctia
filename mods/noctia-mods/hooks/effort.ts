import type { Register } from 'claude-code'

import { EFFORT_FILE, choiceFor, parseChoices } from './choices'

const LEVELS = ['low', 'medium', 'high', 'xhigh', 'max'] as const

/**
 * # Is it an effort level
 * ## Args
 * - value: any text
 * ## Returns
 * True when the text is one of the five effort levels.
 * ## Example
 * isEffort('high') // true
 */
export const isEffort = (value: string | undefined): value is (typeof LEVELS)[number] =>
  LEVELS.includes(value as (typeof LEVELS)[number])

/**
 * # Effort choices
 * Runs every request of a subagent at the effort picked with `/noctia:effort`.
 * The main loop is never touched, and a request without a choice, or whose
 * choice cannot be read, keeps its own effort.
 * ## Args
 * - on: the hook registrar
 */
export const registerEffort: Register = on => {
  on('turn.step', async function* ($, e, next) {
    let effort: string | undefined
    if (e.agentId) {
      try {
        const path = `${await $.session.root()}/${EFFORT_FILE}`
        if (await $.fs.exists(path)) {
          const agent = (await $.agent.list()).find(a => a.id === e.agentId)
          const text = (await $.fs.read(path)) as string
          effort = agent && choiceFor(agent.type, parseChoices(text))
        }
      } catch {
        effort = undefined
      }
    }
    return yield* next(isEffort(effort) ? { ...e, effort } : e)
  })
}
