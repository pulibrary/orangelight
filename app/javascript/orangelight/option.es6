// Simple implementation of an Option/Maybe monad
const Option = {
  Some: (value) => ({
    map: (fn) => Option.Some(fn(value)),
    isSome: () => true,
  }),
  None: () => ({
    map: (_fn) => Option.None(),
    isSome: () => false,
  }),
};
export { Option };
