Demonstrates a bug in the [DiffableDataSources](https://github.com/ra1028/DiffableDataSources) library.

1. Run the app
2. Select cells
3. Scroll to the bottom
4. Select one of the last few cells

Expected: They get selected and the scroll position is kept
Actual: The scroll position jumps around

Uncomment the Podfile line that points to [my fork](https://github.com/rafaelnobrekz/DiffableDataSources/tree/native-when-available) which uses native API when available, and the problem will go away on iOS 13+
