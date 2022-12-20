param counter int

@batchSize(1)
module Delay_Loop_delayLoop './nested_Delay_Loop_delayLoop.bicep' = [for i in range(0, counter): {
  name: 'Delay-Loop-${i}'
  params: {
  }
}]