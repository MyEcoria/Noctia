import { describe, expect, test } from 'claude-code/testing'

import { choiceFor, parseChoices } from './choices'

describe('choices', () => {
  test('parseChoices reads one agent=model per line', () => {
    expect(parseChoices('reader=haiku\ndeveloper=sonnet\n')).toEqual({
      reader: 'haiku',
      developer: 'sonnet',
    })
  })

  test('parseChoices drops malformed lines and lets the last line win', () => {
    expect(parseChoices('reader\n=opus\nreader=haiku\nreader=sonnet\n# note')).toEqual({
      reader: 'sonnet',
    })
    expect(parseChoices('')).toEqual({})
  })

  test('choiceFor finds the choice of a prefixed agent type', () => {
    expect(choiceFor('noctia:reader', { reader: 'haiku' })).toBe('haiku')
  })

  test('choiceFor returns nothing for an agent without a choice', () => {
    expect(choiceFor('Explore', { reader: 'haiku' })).toBeUndefined()
  })
})
