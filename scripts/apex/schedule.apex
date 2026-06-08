GoalRefreshSchedule schedulable = new GoalRefreshSchedule();
String cronExpression = '0 0 0 ? * *';
Id jobId = System.schedule('Refresh Goals Daily', cronExpression, schedulable);