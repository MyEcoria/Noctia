import { describe, expect, test } from 'claude-code/testing'

import { isEffort } from './effort'

const agent = { id: 'a1', description: 'd', type: 'noctia:reader', status: 'running' }

const done = (e: { turnId: string; index: number }) =>
  ({ turnId: e.turnId, index: e.index, answer: '', toolUses: [], stopReason: null, usage: null }) as never

// Fires one model request, of the agent `agentId` or of the main loop, and drains its stream.
const step = async ($: any, agentId?: string) => {
  const stream = $.turn.step({ turnId: 't', index: 0, model: 'm', effort: 'medium', messageCount: 1, agentId })
  while (!(await stream.next()).done);
}

// Stores the choices file the hook reads, and answers in place of the engine with the effort the request carries.
const withChoices = (on: any, file: string) => {
  const seen: { effort?: unknown } = {}
  on('session.root', () => ({ value: '/p' }))
  on('fs.exists', () => ({ value: true }))
  on('fs.read', () => ({ value: file }))
  on('agent.list', () => ({ value: [agent] }))
  on('turn.step', async function* (_: unknown, e: { turnId: string; index: number; effort?: unknown }) {
    seen.effort = e.effort
    return done(e)
  })
  return seen
}

describe('effort levels', () => {
  test('accepts the five levels', () => {
    for (const level of ['low', 'medium', 'high', 'xhigh', 'max']) expect(isEffort(level)).toBe(true)
  })

  test('refuses anything else, default included', () => {
    expect(isEffort('default')).toBe(false)
    expect(isEffort('')).toBe(false)
    expect(isEffort(undefined)).toBe(false)
  })
})

describe('effort choices', () => {
  test('a subagent request runs at the chosen effort', async ($, on) => {
    const seen = withChoices(on, 'reader=high\n')
    await step($, 'a1')
    expect(seen.effort).toBe('high')
  })

  test('an agent without a choice keeps its own effort', async ($, on) => {
    const seen = withChoices(on, 'architect=max\n')
    await step($, 'a1')
    expect(seen.effort).toBe('medium')
  })

  test('the main loop keeps its own effort', async ($, on) => {
    const seen = withChoices(on, 'reader=high\n')
    await step($, undefined)
    expect(seen.effort).toBe('medium')
  })
})
