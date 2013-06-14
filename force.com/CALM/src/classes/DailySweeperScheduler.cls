global class DailySweeperScheduler implements InstallHandler {
	global void onInstall(InstallContext context) {
		if(context.previousVersion() == null) {
			// Schedule Line Graph Sweeper
			String sch = '0 30 0 * * ?';
			system.schedule('Daily Sweeper', sch, new LineGraphSweeper());
		}
	}
}