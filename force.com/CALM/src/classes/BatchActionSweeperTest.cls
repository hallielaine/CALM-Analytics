@isTest
private class BatchActionSweeperTest {
	// BatchActionSweeper is deprecated and now does nothing.
	// This is just to obtain test coverage on an essentially empty class.
    public static testMethod void testBatch() {
        BatchActionSweeper.doNothing();
        system.assert(true);
    }
}