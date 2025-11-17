import { describe } from 'vitest';
import { Option } from '../../../app/javascript/orangelight/option.es6';

describe('Some variant', () => {
  it('can map()', () => {
    let result;
    Option.Some(3).map((num) => (result = num + 2));
    expect(result).toEqual(5);
  });
  it('map() returns another Some', () => {
    const mapped = Option.Some(3).map((num) => num + 2);
    expect(mapped.isSome()).toBe(true);
  });
});
describe('None variant', () => {
  it('can map()', () => {
    let result;
    Option.None().map((num) => (result = num + 2));
    expect(result).not.toBeDefined();
  });
  it('map() returns another None', () => {
    const mapped = Option.None().map((num) => num + 2);
    expect(mapped.isSome()).toBe(false);
  });
});
