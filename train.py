import sklearn
from sklearn import datasets
from sklearn import utils
from sklearn.naive_bayes import GaussianNB
import numpy as np

def write_model_settings(X_train, y, gnb):
  filename = "src/model_settings.h"

  with open(filename, "w") as f:
    line = f"#define NB_OF_CLASSES {len(set(y))}\n"
    line += f"#define VECTOR_DIMENSION {X_train.shape[1]}\n"
    line += f"#define EPSILON {gnb.epsilon_}f\n\n"
    f.write(line)

    # write the theta array
    line = "const float32_t theta[NB_OF_CLASSES*VECTOR_DIMENSION] = {\n"
    for theta in list(np.reshape(gnb.theta_, np.size(gnb.theta_))):
      line += f"\t{theta},\n"
    line = line[:-2] + "\n"
    line += "};\n\n"
    f.write(line)

    # write the sigma array
    line = "const float32_t sigma[NB_OF_CLASSES*VECTOR_DIMENSION] = {\n"
    for sigma in list(np.reshape(gnb.sigma_,np.size(gnb.sigma_))):
      line += f"\t{sigma},\n"
    line = line[:-2] + "\n"
    line += "};\n\n"
    f.write(line)

    # write the priors array
    line = "const float32_t classPriors[NB_OF_CLASSES] = {\n"
    for prior in list(np.reshape(gnb.class_prior_,np.size(gnb.class_prior_))):
      line += f"\t{prior},\n"
    line = line[:-2] + "\n"
    line += "};"
    f.write(line)

  return None

def main():
  print("Loading IRIS dataset...")
  dataset = datasets.load_iris()
  y = dataset.target
  # just take first two columns
  X = dataset.data[:,:2]
  X, y = utils.shuffle(X,y)

  train_perc = 0.8
  train_num = int(len(X) * train_perc)

  X_train, y_train = X[:train_num], y[:train_num]
  X_val, y_val = X[train_num:], y[train_num:]

  print("Initializing Naive Bayes")
  gnb = GaussianNB()
  print("Training model...")
  gnb.fit(X_train, y_train)

  print("Writing to model_settings.h")
  write_model_settings(X_train, y, gnb)

  return None

if __name__ == '__main__':
  main()
