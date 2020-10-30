# Code for Model class

import numpy as np
from math import sqrt
import torch
import torch.nn as nn
import torch.nn.functional as F

class Model(nn.Module):
    def __init__(self, vocab_size):
        super().__init__()

        # define layers
        self.embedding_layer = nn.Embedding(vocab_size + 1, 100)
        self.conv1d_layer = nn.Conv1d(100, 40, 8)
        self.pool_layer = nn.MaxPool1d(kernel_size=2)
        self.flatten_layer = nn.Flatten()
        self.fc1_layer = nn.Linear(13520, 10)
        self.fc2_layer = nn.Linear(10, 2)

        # Initalize weights
        self.init_weights()

    def init_weights(self):
        nn.init.uniform_(self.embedding_layer.weight, -1.0, 1.0)

        for conv in [self.conv1d_layer]:
            C_in = conv.weight.size(1)
            nn.init.normal_(conv.weight, 0.0, 1 / sqrt(5*5*C_in))
            nn.init.constant_(conv.bias, 0.0)

        for fc in [self.fc1_layer, self.fc2_layer]:
            nn.init.normal_(fc.weight, 0.0, 1 / sqrt(fc.weight.size(1)))
            nn.init.constant_(fc.bias, 0.0)


    def forward(self, x):
        z = self.embedding_layer(x)
        z = z.permute(0, 2, 1)
        z = F.relu(self.conv1d_layer(z))
        z = self.pool_layer(z)
        z = self.flatten_layer(z)
        z = F.relu(self.fc1_layer(z))
        return self.fc2_layer(z)

