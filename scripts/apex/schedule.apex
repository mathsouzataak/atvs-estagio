GoalRefreshSchedule schedulable = new GoalRefreshSchedule();
String cronExpression = '0 0 0 ? * *'; // 0h0min0s; Every Month; Every day of the week; 
Id jobId = System.schedule('Refresh Goals Daily', cronExpression, schedulable);