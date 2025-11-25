import { describe, vi } from 'vitest';
import { fadeout } from '../../../app/javascript/orangelight/fadeout';

describe('fadeout', () => {
  it('gradually loses its opacity', () => {
    vi.useFakeTimers();
    document.body.innerHTML = '<span>Fading</span>';
    fadeout(document.querySelector('span'));

    vi.advanceTimersByTime(60);
    expect(document.querySelector('span').style.opacity).toEqual('0.9');

    vi.advanceTimersByTime(60);
    expect(document.querySelector('span').style.opacity).toEqual('0.8');

    vi.advanceTimersByTime(60);
    expect(document.querySelector('span').style.opacity).toEqual('0.7');

    vi.advanceTimersByTime(60);
    expect(document.querySelector('span').style.opacity).toEqual('0.6');

    vi.advanceTimersByTime(60);
    expect(document.querySelector('span').style.opacity).toEqual('0.5');

    vi.advanceTimersByTime(60);
    expect(document.querySelector('span').style.opacity).toEqual('0.4');

    vi.advanceTimersByTime(60);
    expect(document.querySelector('span').style.opacity).toEqual('0.3');

    vi.advanceTimersByTime(60);
    expect(document.querySelector('span').style.opacity).toEqual('0.2');

    vi.advanceTimersByTime(60);
    expect(document.querySelector('span').style.opacity).toEqual('0.1');

    vi.advanceTimersByTime(60);
    expect(document.querySelector('span').style.opacity).toEqual('0');

    vi.restoreAllMocks();
  });
  it('can accept a callback', () => {
    vi.useFakeTimers();
    const callback = vi.fn();
    document.body.innerHTML = '<span>Fading</span>';

    fadeout(document.querySelector('span'), callback);
    vi.advanceTimersByTime(700);
    expect(callback).toHaveBeenCalled();
  });
});
