import pandas as pd
import numpy as np

data = pd.read_csv(
    'data/modes_de_transports_et_perceptions.csv', sep=',', header=None)
responses = np.array(data.iloc[0:, 10:].values)


