@isTest
private class BatchSessionSweeperTest {
	// BatchSessionSweeper is deprecated and now does nothing.
	// This is just to obtain test coverage on an essentially empty class.
    public static testMethod void testBatch() {
        BatchSessionSweeper.doNothing();
        system.assert(true);
    }
}