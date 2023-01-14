public inherited sharing class LimitService {
    public enum LimitName {
        CPU_TIME,
        SOQL_QUERIES
    }

    public class LimitDTO {
        public String name { private set; public get; }
        public Integer usage { private set; public get; }
        public Integer totalLimit { private set; public get; }
        public Integer remaining { private set; public get; }

        @TestVisible
        private LimitDTO(String name, Integer currentUsage, Integer orgLimit) {
            this.name = name;
            this.usage = currentUsage;
            this.totalLimit = orgLimit;
            this.remaining = totalLimit - usage;
        }
    }

    public static LimitDTO getLimit(LimitName limitName) {
        switch on limitName {
            when CPU_TIME {
                return new LimitDTO(limitName.name(), Limits.getCpuTime(), Limits.getLimitCpuTime());
            }
            when SOQL_QUERIES {
                return new LimitDTO(limitName.name(), Limits.getQueries(), Limits.getLimitQueries());
            }
        }

        throw new InvalidParameterValueException('Limit name', limitName.name());
    }
}